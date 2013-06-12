.PHONY: all clean

all: build
	@

src/dist/setup:
	cd src && mirari configure www.conf $(FLAGS) $(CONF_FLAGS)

build: src/dist/setup
	cd src && mirari build www.conf $(FLAGS)

run:
	cd src && sudo mirari run www.conf $(FLAGS)

clean:
	cd src && obuild clean
	rm -f mir-www


xen-%:
	$(MAKE) FLAGS=--xen $*

unix-socket-%:
	$(MAKE) FLAGS="--unix --socket" $*

unix-direct-%:
	$(MAKE) FLAGS="--unix" $*
