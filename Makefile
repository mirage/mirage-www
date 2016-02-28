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

# XENIMG: the name to provide for the xen image and configuration
XENIMG ?= www

# FLAGS for the "mirage configure" command.
FLAGS  ?=

.PHONY: all configure build run clean

all:
	@echo "To build this website, first use \"make prepare\""
	@echo "You can then build the mirage application in the src/ directory"
	@echo "cd src && mirage configure && make"
	@echo "For unikernel configuration option, do \"mirage configure --help\" in src/"

prepare:
	cd stats && make depend
	cd stats && make all

configure: prepare
	mirage configure -f src/config.ml $(FLAGS) -t $(MODE)

depend:
	cd stats && make depend
	cd src && make depend

build:
	cd stats && make build
	cd src && make build

clean:
	cd src && make clean
	cd stats && make clean
	$(RM) log src/mir-www src/*.img src/make-fat*.sh
