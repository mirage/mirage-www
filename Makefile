# -*- mode: Makefile -*-
#
# Copyright (c) 2013 Anil Madhavapeddy <anil@recoil.org>
# Copyright (c) 2013 Richard Mortier <mort@cantab.net>
#
# Permission to use, copy, modify, and distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright
# notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

MODE ?= unix

MIRAGE ?= mirage
MODE   ?= unix
FS     ?= fat
NET    ?= direct
IPADDR ?= static

FLAGS  ?=

.PHONY: all configure build run clean

all:
	@echo "To build this website, look in the Makefile and set"
	@echo "the appropriate variables (MODE, FS, NET, IPADDR)."
	@echo "make configure && make depend && make build"

configure:
	$(MIRAGE) configure src/config.ml $(FLAGS) --$(MODE)

depend:
	cd stats && make depend
	cd src && make depend

build:
	cd stats && make all
	cd src && make build

run:
	cd src && sudo make run

clean:
	cd src && make clean
	cd stats && make clean
	$(RM) log src/mir-www src/*.img src/make-fat*.sh
