all: build

run: build
	./blog_summary

build:
# 
	ocamlfind ocamlopt -syntax camlp4o -package cow -package cow.syntax -package lwt -package cohttp -package cohttp.lwt -package xmlm -package syndic -linkpkg blog_summary.ml -o blog_summary

#test: run

clean:
	rm *.cmi *.cmx *.o


test:
	ocamlfind ocamlopt -package async -package cohttp -package cohttp.async -linkpkg -thread test.ml -o test

runtest: test
	./test
