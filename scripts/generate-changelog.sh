#!/bin/sh
# Need to install `opam install github`

export CONDUIT_TLS=native
git-list-releases `cat TROVE` > tmpl/changelog.md
