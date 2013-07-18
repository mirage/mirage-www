#!/bin/sh -x

if [ `opam list -i mirage-xen -s 2>/dev/null` ]; then
	make xen-build
else
  if [ `opam list -i mirage-net-direct -s 2>/dev/null` ]; then
	make unix-direct-build
  else 
	make unix-socket-build
  fi
fi
