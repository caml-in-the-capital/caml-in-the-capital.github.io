open Yocaml

module Talk : sig
  type t =
    { title : string
    ; speakers : string list
    ; abstract : string
    ; link : string option
    ; slug : string
    }

  include Data.S with type t := t
end

type t =
  { talks : Talk.t list
  ; location : string
  ; date : Archetype.Datetime.t
  }

val format_date : Archetype.Datetime.t -> string

include Data.S with type t := t

val split : t list -> t list * t list
val read_dir : Path.t -> t Eff.t
val fetch : Path.t -> (unit, t list) Task.t
