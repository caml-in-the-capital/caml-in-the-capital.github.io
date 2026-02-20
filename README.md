# Caml in the Capital

Static website for the Caml in the Capital meetup group, built with [YOCaml](https://yocaml.github.io/).

## Getting Started

### Building the Website

Build the static site:

```bash
dune exec caml_in_the_capital -- build
```

The generated site will be in the `_www` directory.

### Running Locally

Build and serve the website with hot reloading:

```bash
dune exec caml_in_the_capital -- serve
```

By default, the site will be available at http://localhost:8000

## Adding Content

### Adding a New Meeting

1. Create a directory in `content/meetings/` with the date: `YYYY-MM-DD`
2. Add an `_index.md` file with meeting metadata
3. Add individual talk files as `.md` files in the same directory

## License

MIT
