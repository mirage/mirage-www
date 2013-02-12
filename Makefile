.PHONY: all clean

XEN?= $(shell if ocamlfind query lwt.unix >/dev/null 2>&1; then echo ""; else echo "--xen"; fi)

all: build
	@

src/dist/setup:
	cd src && mirari configure www.conf $(XEN)

build: src/dist/setup
	cd src && mirari build www.conf $(XEN)

run:
	./mir-www

clean:
	cd src && obuild clean
	$(RM) mir-www
