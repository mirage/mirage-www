all: 
	./cmd config
	mir-crunch -name "static" ../files > filesystem_static.ml
	mir-crunch -name "templates" ../tmpl > filesystem_templates.ml
	echo open Filesystem_static > main.ml
	echo open Filesystem_templates >> main.ml
	echo open Server >> main.ml
	echo "let _ = OS.Main.run (main ())" >> main.ml
	ocamlbuild -classic-display main.native

.PHONY:clean
clean:
	rm -f filesystem_static.ml filesystem_templates.ml mail.ml
	ocamlbuild -clean
