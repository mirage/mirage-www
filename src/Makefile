.PHONY:all
all: filesystem_static.ml filesystem_templates.ml
	@ :

filesystem_static.ml: ../files/*
	mlcrunch ../files > $@

filesystem_templates.ml: ../tmpl/*
	mlcrunch ../tmpl > $@

.PHONY:clean
clean:
	rm -f filesystem_static.ml filesystem_templates.ml
