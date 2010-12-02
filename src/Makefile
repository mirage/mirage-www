.PHONY:all clean
all: filesystem_static.ml filesystem_templates.ml bin
	@ :

filesystem_static.ml: ../files/*
	mlcrunch ../files > $@

filesystem_templates.ml: ../tmpl/*
	mlcrunch ../tmpl > $@

bin: filesystem_static.ml filesystem_templates.ml
	mir mirage-www.unix

.PHONY:clean
clean:
	rm -f filesystem_static.ml filesystem_templates.ml
	rm -f myocamlbuild.ml
	ocamlbuild -clean
