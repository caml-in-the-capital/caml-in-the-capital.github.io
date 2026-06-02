---
title: "Opam’s Nix system dependency mechanism"
speakers:
  - Ryan Gibb
---

The OCaml language package manager, Opam, has support for interfacing with
system package mangers to provide dependencies external to the language.
Supporting Nix, the package manager which pioneered the functional software
deployment model, required re-thinking the abstractions used to interface with
traditional package managers, but enables using Opam for development easily
whilst benefitting from Nix’s reproducible system dependencies. This provides
one example of how Nix interfaces with other software development and
deployment technologies.
