#!/bin/bash -ex

BIN=kv_ro_server
MIR_RUN=$(which mir-run)

dd if=/dev/zero of=../files.img bs=1024 count=8192
dd if=/dev/zero of=../tmpl.img bs=1024 count=8192
mir-fs-create ../files ../files.img
mir-fs-create ../tmpl ../tmpl.img

mir-build xen/${BIN}.xen
sudo ${MIR_RUN} -b xen -vif xenbr0 -vbd hda1:../files.img -vbd hda2:../tmpl.img -kv_ro static:hda1 kv_ro templates:hda2 ./_build/xen/${BIN}.xen
