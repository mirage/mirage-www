.PHONY: all clean

all:
	cd src && $(MAKE)
	ln -nsf src/_build/mirage-www.bin .

clean:
	rm -f mirage-www.bin
	cd src && $(MAKE) clean
