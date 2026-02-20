final: prev:
with prev; {
  ocamlPackages = final.ocaml-ng.ocamlPackages_5_2;

  ocaml-ng =
    ocaml-ng
    // (with ocaml-ng; {
      ocamlPackages_5_2 = ocamlPackages_5_2.overrideScope (
        _: prev:
          with prev; let
            yocamlPkg = pname: deps:
              buildDunePackage rec {
                inherit pname;
                version = "2.8.0";
                src = fetchFromGitHub {
                  owner = "xhtmlboi";
                  repo = "yocaml";
                  rev = "v${version}";
                  hash = "sha256-wuKPv9bFV2DEV5KwfZxnYavtqaCs8OO/iKI2F3qF+4w=";
                };

                propagatedBuildInputs = deps;
              };
          in rec {
            yocaml = yocamlPkg "yocaml" [logs ppx_expect];
            yocaml_runtime = yocamlPkg "yocaml_runtime" [yocaml cohttp logs fmt digestif magic-mime ppx_expect];
            yocaml_unix = yocamlPkg "yocaml_unix" [yocaml yocaml_runtime httpcats ppx_expect];
            yocaml_jingoo = yocamlPkg "yocaml_jingoo" [yocaml jingoo ppx_expect];
            yocaml_markdown = yocamlPkg "yocaml_markdown" [yocaml cmarkit textmate-language hilite ppx_expect];
            yocaml_yaml = yocamlPkg "yocaml_yaml" [yaml yocaml ppx_expect];
            httpcats = buildDunePackage {
              pname = "httpcats";
              version = "0.1.0";

              src = fetchFromGitHub {
                owner = "robur-coop";
                repo = "httpcats";
                rev = "v0.1.0";
                hash = "sha256-t3gSfv73XYntle1dd4k9bv893pGStk1NHz62mAvcHAs=";
              };

              propagatedBuildInputs = [miou h1 h2 ca-certs bstr digestif tls-miou-unix happy-eyeballs-miou-unix dns-client-miou-unix];
            };
            tls-miou-unix = buildDunePackage {
              pname = "tls-miou-unix";
              inherit (tls) src version;

              propagatedBuildInputs = [
                tls
                x509
                miou
              ];
            };
            happy-eyeballs-miou-unix = buildDunePackage {
              pname = "happy-eyeballs-miou-unix";
              inherit (happy-eyeballs) src version;

              propagatedBuildInputs = [
                happy-eyeballs
                miou
                mtime
                duration
                domain-name
                ipaddr
                fmt
                logs
                cmdliner
              ];
            };
            dns-client-miou-unix = buildDunePackage {
              pname = "dns-client-miou-unix";
              inherit (dns-client) src version;

              propagatedBuildInputs = [
                happy-eyeballs-miou-unix
                tls-miou-unix
                ipaddr
                dns-client
                happy-eyeballs
                miou
                domain-name
              ];
            };
          }
      );
    });
}
