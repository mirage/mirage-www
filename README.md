# Mirage.io

Website infrastructure and content for mirage.io

## Set up your development environment

You need opam. You can install it by following [opam's documentation](https://opam.ocaml.org/doc/Install.html).

With opam installed, you can install the dependencies in a new local switch with:

```bash
make switch
```

Or globally, with:

```bash
make deps
```

You'll also need to download the TailwindCSS CLI. You can follow the [TailwindCSS documentation](https://tailwindcss.com/blog/standalone-cli#get-started) to do this. Put the binary in `/tailwindcss`.

Make sure to give execution rights to the file:

```
chmod +x tailwindcss
```

Then, build the project with:

```bash
make build
```

### Running the server

After building the project, you can run the server with:

```bash
make start
```

To start the server in watch mode, you can run:

```bash
make watch
```

This will restart the server on filesystem changes and reload the pages automatically.

### MirageOS unikernel

Alternatively, the `mirage/` folder implements the webserver as a MirageOS 4 unikernel.
To set it up, install the _mirage_ tool:

```bash
opam repo add mirage-dev https://github.com/mirage/mirage-dev.git # until MirageOS 4 is released
opam install "mirage>=4.0.0"
```

Then, the unikernel can be _configured_:

```bash
mirage configure -f mirage/config.ml -t <TARGET> ...
```

Fetch the dependencies:

```bash
make depends
```

Build the unikernel:

```bash
dune build mirage/
```

Clean up:

```bash
mirage clean -f mirage/config.ml
rm -rf mirage/duniverse
```
