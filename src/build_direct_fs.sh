#!/bin/bash -e

BIN=kv_ro_server
MIR_RUN=$(which mir-run)

dd if=/dev/zero of=../files.img bs=1024 count=8192
dd if=/dev/zero of=../tmpl.img bs=1024 count=8192
mir-fs-create ../files ../files.img
mir-fs-create ../tmpl ../tmpl.img
mir-build unix-direct/${BIN}.bin
sudo ${MIR_RUN} -b unix-direct -vbd filesvbd:../files.img -vbd tmplvbd:../tmpl.img -kv_ro files:filesvbd -kv_ro tmpl:tmplvbd ./_build/unix-direct/${BIN}.bin
