LIBS = -pkgs lwt.syntax,cow.syntax,cowabloga,lwt,cohttp,cohttp.lwt,xmlm,syndic

SYNTAX = -tags "syntax(camlp4o)"

.PHONY: all run build clean test

all: build

run: build
	@echo "updating news pages"
	@./news.native

build:
	ocamlbuild -use-ocamlfind $(LIBS) $(SYNTAX) news.native

clean:
	rm *.cmi *.cmx *.o *.html
