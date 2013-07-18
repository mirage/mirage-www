.PHONY: all clean

all: build
	@ :

configure:
	cd src && mirari configure www.conf $(FLAGS) $(CONF_FLAGS)

build: configure
	cd src && mirari build www.conf $(FLAGS)

run:
	cd src && sudo mirari run www.conf $(FLAGS)

clean:
	cd src && mirari clean www.conf
	rm -f mir-www

xen-%:
	$(MAKE) FLAGS=--xen $*

unix-socket-%:
	$(MAKE) FLAGS="--unix --socket" $*

unix-direct-%:
	$(MAKE) FLAGS="--unix" $*
