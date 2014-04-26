#!/bin/sh
# Need to install `opam install github`

git-list-releases `cat TROVE` > tmpl/changelog.md
