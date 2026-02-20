{
  description = "Caml in the Capital website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    with inputs;
      flake-utils.lib.eachDefaultSystem (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ocaml-overlay.overlays.default (import ./nix/overlay.nix)];
          };

          ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_2;

          treefmtConfig = treefmt.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.alejandra.enable = true;
            programs.ocamlformat.enable = true;
            settings.global.excludes = ["result" ".direnv" "_build"];
          };

          citc = pkgs.callPackage ./nix/caml-in-the-capital.nix {};
          www = pkgs.callPackage ./nix/www.nix {inherit citc;};
        in {
          packages = {
            default = www;
            www = www;
            citc = citc;
          };

          formatter = treefmtConfig.config.build.wrapper;

          devShells.default = pkgs.mkShell {
            inputsFrom = [citc];
            buildInputs = with pkgs; [
              # Formatters
              alejandra
              ocamlformat

              # OCaml development tools
              ocamlPackages.utop
              ocamlPackages.ocaml-lsp
              ocamlPackages.merlin
              ocamlPackages.merlin-lib
              ocamlPackages.ocaml
              ocamlPackages.dune
            ];
          };
        }
      );
}
