{
  lib,
  ocamlPackages,
}:
with ocamlPackages;
  buildDunePackage {
    pname = "caml_in_the_capital";
    version = "dev";

    src = lib.cleanSource ../.;

    propagatedBuildInputs = [
      core
      core_unix
      ppx_jane
      yocaml
      yocaml_unix
      yocaml_jingoo
      yocaml_markdown
      yocaml_yaml
    ];
  }
