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

MIRAGE ?= mirage
# MODE: unix for Unix executable, xen for Xen unikernel
MODE   ?= unix
# FS: crunch for in-memory read-only store, fat for read-write filesystem
FS     ?= crunch
# NET: direct for mirage network stack, socket for unix sockets (Unix mode only)
NET    ?= direct
# XENIMG: the name to provide for the xen image and configuration
XENIMG ?= www
# HOST: all links will be relative to this domain; default is localhost
HOST   ?= localhost

# to configure the network via DHCP:
# DHCP = true

# to configure the network statically with ip 10.0.0.2/24 and gateway 10.0.0.1:
# IP = "10.0.0.2"
# NETMASK = "255.255.255.0"
# GATEWAYS = "10.0.0.1"
#
# if none of DHCP || (IP && NETMASK && GATEWAYS) is set,
# default static settings will be used.

# to serve pages over https:
# TLS = true
# to make it work with FS=crunch, put the certificate in tls/tls/server.key and the private key in tls/tls/server.pem

# to redirect all http requests to https://somewhereelse.org:
# REDIRECT = https://somewhereelse.org 
# (redirect must be an http:// or https:// url)
# if TLS is set but REDIRECT is not, the value of REDIRECT will be assumed to be https://$HOST , with the effect that all http requests will be redirected to https

FLAGS  ?=

.PHONY: all configure build run clean

all:
	@echo "To build this website, look in the Makefile and set"
	@echo "the appropriate variables (MODE, FS, NET, DHCP, REDIRECT, HOST, TLS)."
	@echo "make configure && make depend && make build"

configure:
	cd stats && make depend
	# the make depend in src will crunch the stats into the fs:
	cd stats && make all
	$(MIRAGE) configure src/config.ml $(FLAGS) --$(MODE)

depend:
	cd stats && make depend
	cd src && make depend

build:
	cd stats && make build
	cd src && make build

run:
	cd src && sudo make run

clean:
	cd src && make clean
	cd stats && make clean
	$(RM) log src/mir-www src/*.img src/make-fat*.sh
