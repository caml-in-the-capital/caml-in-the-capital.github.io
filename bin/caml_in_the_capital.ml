open Core

module Params = struct
  let parse_log_level = function
    | "app" -> `App
    | "error" -> `Error
    | "warn" -> `Warning
    | "info" -> `Info
    | "debug" -> `Debug
    | level -> invalid_argf "%S is an invalid log level" level ()
  ;;

  let parse_port s =
    let raise_invalid () = invalid_argf "%S is an invalid port number" s () in
    match Int.of_string s with
    | exception _ -> raise_invalid ()
    | n when n < 1 || n > 65535 -> raise_invalid ()
    | n -> n
  ;;

  let log_level ~default =
    Command.Spec.flag
      "-log-level"
      (Command.Flag.optional_with_default
         default
         (Command.Arg_type.create parse_log_level))
      ~doc:"LEVEL log level passed to Yocaml runtime"
  ;;

  let port ~default =
    Command.Spec.flag
      "-port"
      (Command.Flag.optional_with_default default (Command.Arg_type.create parse_port))
      ~doc:"PORT port number used to serve the website"
  ;;
end

module Command = struct
  let serve =
    Command.basic_spec
      ~summary:"Builds and serves the Caml in the Capital website"
      Command.Spec.(empty +> Params.log_level ~default:`Info +> Params.port ~default:8000)
      (fun log_level port () -> Website.serve ~log_level ~port)
  ;;

  let build =
    Command.basic_spec
      ~summary:"Builds the Caml in the Capital website"
      Command.Spec.(empty +> Params.log_level ~default:`Debug)
      (fun log_level () -> Website.build ~log_level)
  ;;

  let v =
    Command.group ~summary:"Caml in the Capital SSG" [ "serve", serve; "build", build ]
  ;;
end

let () = Command_unix.run Command.v
