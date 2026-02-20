(lang dune 3.16)

(name caml_in_the_capital)

(generate_opam_files true)

(source
 (github caml-in-the-capital/caml-in-the-capital.github.io))

(authors "Alistair O'Brien")

(maintainers "Alistair O'Brien")

(license MIT)

(package
 (name caml_in_the_capital)
 (synopsis "Caml in the Capital website")
 (depends
  (ocaml (>= 5.2))
  dune
  core
  ppx_jane
  core_unix
  yocaml
  yocaml_unix
  yocaml_yaml
  yocaml_jingoo
  yocaml_markdown))
