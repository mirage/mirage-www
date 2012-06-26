.PHONY: all clean

all:
	cd src && $(MAKE)

xen:
	cd src && $(MAKE) xen

clean:
	cd src && $(MAKE) clean

run:
	sudo ./src/_build/main.native
