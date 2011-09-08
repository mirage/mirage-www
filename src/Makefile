.PHONY:all clean
all: filesystem_static.ml filesystem_templates.ml bin
	@ :

filesystem_static.ml: ../files/*
	mir-crunch -name "static" ../files > $@

filesystem_templates.ml: ../tmpl/*
	mir-crunch -name "templates" ../tmpl > $@

bin: filesystem_static.ml filesystem_templates.ml
	mir-build -j 5 unix-socket/server.bin

.PHONY:clean
clean:
	rm -f filesystem_static.ml filesystem_templates.ml
	rm -f myocamlbuild.ml
	ocamlbuild -clean
