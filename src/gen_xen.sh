#!/bin/sh

TARGET=main
if [ -e ./_build/${TARGET}.nobj.o ]; then
  mir-build -b xen-native -o ./_build/${TARGET}.xen ./_build/${TARGET}.nobj.o
fi
