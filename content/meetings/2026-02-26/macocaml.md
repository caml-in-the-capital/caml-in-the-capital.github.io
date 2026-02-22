---
title: "Compile-time Computation for Caml"
speakers:
  - "Jeremy Yallop"
---

The [Modular Macros project](https://www.cl.cam.ac.uk/~jdy22/projects/modular-macros/) extends OCaml with new language features for compile-time computation and typed code quotations, allowing programmers to write high-level libraries that apply domain-specific optimizations to safely generate efficient low-level code.

Our design draws heavily on existing work in metaprogramming, taking inspiration from ideas that have been proven in practice in languages such as MetaOCaml, Template Haskell, and Racket. However, smooth and safe integration with OCaml's existing features such as effect handlers and the module system poses some new challenges.

This talk will give a high-level overview of ongoing work on the language design, the underlying theory, the implementation and some applications.
