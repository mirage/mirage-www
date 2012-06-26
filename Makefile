.PHONY: all clean

all:
	cd src && $(MAKE)

clean:
	cd src && $(MAKE) clean

run:
	sudo ./src/_build/main.native
