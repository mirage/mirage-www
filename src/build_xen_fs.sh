#!/bin/bash -ex

BIN=kv_ro_server
MIR_RUN=$(which mir-run)

dd if=/dev/zero of=../files.img bs=1024 count=8192
dd if=/dev/zero of=../tmpl.img bs=1024 count=8192
mir-fs-create ../files ../files.img
mir-fs-create ../tmpl ../tmpl.img

files_vbd=$(readlink -f ../files.img)
tmpl_vbd=$(readlink -f ../tmpl.img)

echo files=$files_vbd
echo tmpl=$tmpl_vbd
mir-build xen/${BIN}.xen
sudo ${MIR_RUN} -b xen -vif xenbr0 -vbd ${files_vbd},hda1,r -vbd ${tmpl_vbd},hda2,r -kv_ro static:hda1 kv_ro templates:hda2 ./_build/xen/${BIN}.xen
