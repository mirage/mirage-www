PKGS  = dune lwt_log js_of_ocaml js_of_ocaml-lwt c3 uri xapi-rrd re
BUILD = dune build --profile release
OPAM  = opam

export OPAMVERBOSE=1
export OPAMYES=1

.PHONY: all depend clean build main.byte install
all:: build install

install: build
	mkdir -p ../files/js/stats
	cp _build/default/main.bc.js ../files/js/stats/main.js

depend::
	$(OPAM) install $(PKGS) --verbose

build: main.ml
	$(BUILD) main.bc.js

clean::
	dune clean
