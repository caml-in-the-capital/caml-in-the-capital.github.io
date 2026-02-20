{
  lib,
  stdenv,
  citc,
}:
stdenv.mkDerivation {
  name = "caml-in-the-capital-site";
  src = lib.cleanSource ../.;
  nativeBuildInputs = [citc];
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    caml_in_the_capital build
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r _www/* $out/
    runHook postInstall
  '';
}
