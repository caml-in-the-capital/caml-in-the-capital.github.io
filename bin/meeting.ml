open Core
open Yocaml

let is_markdown file = Path.has_extension "md" file

let is_index file =
  match Path.basename file with
  | Some name -> String.equal name "_index.md"
  | None -> false
;;

let is_talk_file file = is_markdown file && not (is_index file)

module Meta = struct
  type t =
    { location : string
    ; date : Archetype.Datetime.t
    }

  let entity_name = "Meeting"
  let neutral = Error (Required.Required_metadata { entity = entity_name })

  let validate =
    let open Data.Validation in
    record (fun fields ->
      let+ location = required fields "location" string
      and+ date = required fields "datetime" Archetype.Datetime.validate in
      { location; date })
  ;;
end

module Talk = struct
  module Meta = struct
    type t =
      { title : string
      ; speakers : string list
      ; link : string option
      }

    let entity_name = "Talk"
    let neutral = Error (Required.Required_metadata { entity = entity_name })

    let validate =
      let open Data.Validation in
      record (fun fields ->
        let+ title = required fields "title" string
        and+ speakers = required fields "speakers" (list_of string)
        and+ link = optional fields "link" string in
        { title; speakers; link })
    ;;
  end

  type t =
    { title : string
    ; speakers : string list
    ; abstract : string (** HTML, converted from the markdown body *)
    ; link : string option
    ; slug : string (** e.g. "2026-02-26-macocaml" *)
    }

  let to_data { title; speakers; abstract; link; slug } =
    let open Data in
    record
      [ "title", string title
      ; "speakers_str", string (String.concat ~sep:", " speakers)
      ; "abstract", string abstract
      ; "link", option string link
      ; "has_link", bool (Option.is_some link)
      ; "url", string ("/talks/" ^ slug ^ ".html")
      ]
  ;;

  let read ~dir_name talk_file =
    let open Eff in
    let+ (meta : Meta.t), abstract_md =
      Yocaml_yaml.Eff.read_file_with_metadata (module Meta) ~on:`Source talk_file
    in
    let stem =
      Option.value ~default:"" (Path.basename (Path.remove_extension talk_file))
    in
    { title = meta.title
    ; speakers = meta.speakers
    ; link = meta.link
    ; abstract = Yocaml_markdown.from_string_to_html abstract_md
    ; slug = dir_name ^ "-" ^ stem
    }
  ;;
end

let format_date dt =
  let open Archetype.Datetime in
  let month_name =
    match dt.month with
    | Jan -> "January"
    | Feb -> "February"
    | Mar -> "March"
    | Apr -> "April"
    | May -> "May"
    | Jun -> "June"
    | Jul -> "July"
    | Aug -> "August"
    | Sep -> "September"
    | Oct -> "October"
    | Nov -> "November"
    | Dec -> "December"
  in
  Format.sprintf "%d %s %d" (dt.day :> int) month_name (dt.year :> int)
;;

let format_time dt =
  let open Archetype.Datetime in
  Format.sprintf "%02d:%02d" (dt.hour :> int) (dt.min :> int)
;;

type t =
  { talks : Talk.t list
  ; location : string
  ; date : Archetype.Datetime.t
  }

let date t = t.date [@@inline]

let to_data { date; talks; location } =
  let open Data in
  record
    [ "talks", list_of Talk.to_data talks
    ; "date", Archetype.Datetime.normalize date
    ; "date_display", string (format_date date)
    ; "time_display", string (format_time date)
    ; "location", string location
    ]
;;

let read_dir meeting_dir =
  let open Eff in
  let* (meta : Meta.t), _ =
    Yocaml_yaml.Eff.read_file_with_metadata
      (module Meta)
      ~on:`Source
      Path.(meeting_dir / "_index.md")
  in
  let dir_name = Option.value ~default:"" (Path.basename meeting_dir) in
  let* talk_files =
    Eff.read_directory ~on:`Source ~only:`Files ~where:is_talk_file meeting_dir
  in
  let* talks = Eff.List.traverse (Talk.read ~dir_name) talk_files in
  return { talks; date = meta.date; location = meta.location }
;;

let get_today () =
  let tm = Core_unix.(gettimeofday () |> gmtime) in
  Archetype.Datetime.make
    ~time:(tm.tm_hour, tm.tm_min, tm.tm_sec)
    ~year:(tm.tm_year + 1900)
    ~month:(tm.tm_mon + 1)
    ~day:tm.tm_mday
    ()
  |> Result.ok
  |> Option.value_exn ~here:[%here]
;;

let split meetings =
  let today = get_today () in
  let is_upcoming m = Archetype.Datetime.(m.date >= today) in
  meetings
  |> List.sort ~compare:(Comparable.lift Archetype.Datetime.compare ~f:date)
  |> List.partition_tf ~f:is_upcoming
;;

let fetch meetings_dir =
  Pipeline.fetch ~only:`Directories (fun dir -> read_dir dir) meetings_dir
;;
