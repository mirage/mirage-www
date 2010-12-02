.PHONY: all clean

all:
	cd src && $(MAKE)
	ln -nsf src/_build/mirage-www.unix .

clean:
	rm -f mirage-www.unix
	cd src && $(MAKE) clean
