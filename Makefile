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

HTTPPORT ?= 80
HTTPSPORT ?= 443
FLAGS ?= \
  -vv --net socket -t unix --http-port $(HTTPPORT) --https-port $(HTTPSPORT)

MIRAGE = DOCKER_FLAGS="$$DOCKER_FLAGS -p $(HTTPPORT) -p $(HTTPSPORT)" \
    dommage --dommage-chdir src
EXEC_IN = dommage --dommage-chdir

.PHONY: all clean prepare configure build publish destroy

all:
	@echo "To build this website, first use \"make prepare\""
	@echo "You can then build the mirage application in the src/ directory"
	@echo "\"make configure build\""

clean:
	$(EXEC_IN) stats run make clean
	$(RM) -r src/_build
	$(MIRAGE) clean || true
	$(MIRAGE) destroy || true

prepare:
	[ -z ".mirage.container" ] && dommage init $$(cat .mirage.image) || true
	$(EXEC_IN) stats run make depend
	$(EXEC_IN) stats run make all

configure:
	$(MIRAGE) configure $(FLAGS)

build:
	$(EXEC_IN) stats run make build
	$(MIRAGE) build

test:
	$(MIRAGE) run sudo ./www

publish:
	$(MIRAGE) publish mor1/mirage-www

destroy:
	$(MIRAGE) destroy
