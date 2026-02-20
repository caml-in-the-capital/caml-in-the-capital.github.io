open Core
open Yocaml

let source_root = Path.rel []
let target_root = Path.rel [ "_www" ]

module Source = struct
  let templates = Path.(source_root / "templates")
  let template file = Path.(templates / file)
  let css = Path.(source_root / "css")
  let meetings = Path.(source_root / "content" / "meetings")
  let layout_template = template "layout.html"
  let index_template = template "index.html"
  let talk_template = template "talk.html"
end

module Target = struct
  let cache = Path.(target_root / "cache")
  let pages = target_root
  let talks = Path.(target_root / "talks")
end

let track_sources =
  let ml_and_mli comp_unit = [ comp_unit ^ ".ml"; comp_unit ^ ".mli" ] in
  let bin_units comp_units =
    comp_units
    |> List.concat_map ~f:(fun comp_unit ->
      ml_and_mli comp_unit |> List.map ~f:(fun file -> Path.(source_root / "bin" / file)))
  in
  Pipeline.track_files (bin_units [ "caml_in_the_capital"; "meeting"; "website" ])
;;

module Index = struct
  type t =
    { upcoming : Meeting.t list
    ; past : Meeting.t list
    }

  let make ~upcoming ~past = { upcoming; past }

  let normalize { upcoming; past } =
    let open Data in
    [ "page_title", string "Caml in the Capital"
    ; "description", string "London's OCaml meetup"
    ; "upcoming_meetings", list_of Meeting.to_data upcoming
    ; "past_meetings", list_of Meeting.to_data past
    ; "has_upcoming_meetings", bool (not (List.is_empty upcoming))
    ; "has_past_meetings", bool (not (List.is_empty past))
    ]
  ;;
end

let index_rule =
  let open Task in
  Action.Static.write_file
    Path.(Target.pages / "index.html")
    (let+ () = track_sources
     and+ template =
       Yocaml_jingoo.read_templates [ Source.index_template; Source.layout_template ]
     and+ meetings = Meeting.fetch Source.meetings in
     let upcoming, past = Meeting.split meetings in
     let meta = Index.make ~upcoming ~past in
     template (module Index) ~metadata:meta "")
;;

module Talk_page = struct
  type t =
    { title : string
    ; speakers_str : string
    ; meeting_location : string
    ; meeting_date_display : string
    ; abstract : string
    ; has_link : bool
    ; link : string option
    }

  let make ~(meeting : Meeting.t) ~(talk : Meeting.Talk.t) =
    { title = talk.title
    ; speakers_str = String.concat ~sep:", " talk.speakers
    ; meeting_location = meeting.location
    ; meeting_date_display = Meeting.format_date meeting.date
    ; abstract = talk.abstract
    ; has_link = Option.is_some talk.link
    ; link = talk.link
    }
  ;;

  let normalize
        { title
        ; speakers_str
        ; meeting_date_display
        ; meeting_location
        ; abstract
        ; has_link
        ; link
        }
    =
    let open Data in
    [ "title", string title
    ; "page_title", string (title ^ " — Caml in the Capital")
    ; "description", string (speakers_str ^ " at Caml in the Capital")
    ; "speakers_str", string speakers_str
    ; "meeting_date_display", string meeting_date_display
    ; "meeting_location", string meeting_location
    ; "abstract", string abstract
    ; "has_link", bool has_link
    ; "link", option string link
    ]
  ;;
end

let write_talk_page (meeting : Meeting.t) (talk : Meeting.Talk.t) cache =
  let target = Path.(Target.talks / (talk.slug ^ ".html")) in
  let open Task in
  Action.Static.write_file
    target
    (let+ () = track_sources
     and+ template =
       Yocaml_jingoo.read_templates [ Source.talk_template; Source.layout_template ]
     in
     let meta = Talk_page.make ~meeting ~talk in
     template (module Talk_page) ~metadata:meta "")
    cache
;;

let talk_rules_for_meeting meeting_dir cache =
  let open Eff in
  let* meeting = Meeting.read_dir meeting_dir in
  Action.batch_list meeting.talks (write_talk_page meeting) cache
;;

let talk_rules =
  Batch.iter_children ~only:`Directories Source.meetings talk_rules_for_meeting
;;

let css_rule = Action.copy_directory ~into:target_root Source.css

let main_rule () =
  let open Eff in
  Action.restore_cache ~on:`Source Target.cache
  >>= css_rule
  >>= index_rule
  >>= talk_rules
  >>= Action.store_cache ~on:`Source Target.cache
;;

let serve ~log_level ~port =
  Yocaml_unix.serve ~level:log_level ~target:target_root ~port main_rule
;;

let build ~log_level = Yocaml_unix.run ~level:log_level main_rule
