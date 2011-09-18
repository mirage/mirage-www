#!/bin/bash -e

BIN=kv_ro_server
MIR_RUN=$(which mir-run)

mir-build unix-socket/${BIN}.bin
sudo strace ${MIR_RUN} -b unix-socket -kv_ro static:../files -kv_ro templates:../tmpl ./_build/unix-socket/${BIN}.bin
