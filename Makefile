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

HTTP  ?= 8080
HTTPS ?= 4343
FLAGS ?= \
  -vv --net socket -t unix --http-port $(HTTP) --https-port $(HTTPS)

MIRAGE = DOCKER_FLAGS="$$DOCKER_FLAGS -p $(HTTP):$(HTTP) -p $(HTTPS):$(HTTPS)" \
    dommage --dommage-chdir src
EXEC_IN = dommage --dommage-chdir

.PHONY: all
all:
	@echo "To build this website, first use \"make prepare\""
	@echo "You can then build the mirage application in the src/ directory"
	@echo "\"make configure build\""

.PHONY: clean
clean:
	$(EXEC_IN) stats run make clean
	$(RM) -r src/_build
	$(MIRAGE) clean || true

.PHONY: prepare
prepare:
	[ -z ".mirage.container" ] && dommage init $$(cat .mirage.image) || true
	$(EXEC_IN) stats run make depend
	$(EXEC_IN) stats run make all

.PHONY: configure
configure:
	$(MIRAGE) configure $(FLAGS)

.PHONY: build
build:
	$(EXEC_IN) stats run make build
	$(MIRAGE) build

.PHONY: destroy
destroy:
	$(MIRAGE) destroy

.PHONY: update
update:
	$(MIRAGE) update

.PHONY: publish
publish:
	$(MIRAGE) publish mor1/mirage-www

.PHONY: run
run:
	$(MIRAGE) run sudo ./www
