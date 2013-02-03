.PHONY: all clean

all: build
	@

src/dist/setup:
	mirari configure src/www.conf

build: src/dist/setup
	mirari build src/www.conf

run:
	./mir-www

clean:
	cd src && obuild clean
