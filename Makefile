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

CFLAGS ?=
BFLAGS ?=
RFLAGS ?=

MIRAGE ?= mirage
MODE ?= unix
FS ?= fat
NET ?= direct
IPADDR ?= static

.PHONY: all configure build run clean

all: build
	@ :

configure:
	$(MIRAGE) configure src/config.ml $(CFLAGS) --$(MODE)

depend:
	cd src && $(MAKE) depend

build: configure
	$(MIRAGE) build src/config.ml $(BFLAGS)

run: build
	$(MIRAGE) run src/config.ml $(RFLAGS)

clean:
	$(MIRAGE) clean src/config.ml $(BFLAGS)
