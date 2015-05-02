LIBS = -pkgs lwt.syntax,cow.syntax,cowabloga,lwt,cohttp,cohttp.lwt,xmlm,syndic
PKGS   = cow cowabloga lwt cohttp xmlm syndic
SYNTAX = -tags "syntax(camlp4o)"
OPAM = opam

.PHONY: all depend run build clean

all: build

depend:
	$(OPAM) install $(PKGS) --verbose

run: build
	@echo "updating news pages"
	@./news.native

build: depend
	ocamlbuild -use-ocamlfind $(LIBS) $(SYNTAX) news.native

clean:
	ocamlbuild -clean
