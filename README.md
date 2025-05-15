# Mirageos.org

Website infrastructure and content for mirageos.org

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

Then, build the project with:

```bash
make build
```

### Running the server

After building the project, you can run the server with:

```bash
make start
```

The server runs on port `8080` by default. To change the port, set the
`MIRAGE_WWW_PORT` environment variable:

```bash
MIRAGE_WWW_PORT=8088 make start
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


Complete build instruction for the current state
``` bash
make deps
make build
make start # Run on unix
mirage configure -f mirage/config.ml -t hvt # Creates the dune-workspace but no makefile
cd mirage/
mirage configure -f config.ml -t hvt
opam pin .. # not --kind=path because that breaks make depends?
make depends
make build # throws an error. Not necessary?
cd ..
rm -rf mirage/duniverse/mirage-www
dune build mirage
solo5-hvt mirage/dist/www.hvt
```
