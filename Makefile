.PHONY: all run clean test fs

all: build
	@ :

configure:
	cd src && mirari configure www.conf $(FLAGS) $(CONF_FLAGS)

build: configure
	cd src && mirari build www.conf $(FLAGS)

run:
	cd src && sudo `which mirari` run www.conf $(FLAGS)

clean:
	if [ -r src/Makefile ]; then cd src && mirari clean www.conf ; fi
	$(RM) src/myocamlbuild.ml src/filesystem_static.ml

test: unix-socket-build unix-socket-run

fs: 
	mir-crunch -o src/filesystem_static.ml -name "static" ./files

xen-%:
	$(MAKE) FLAGS=--xen $*

unix-socket-%:
	$(MAKE) FLAGS="--unix --socket" $*

unix-direct-%:
	$(MAKE) FLAGS="--unix" $*
