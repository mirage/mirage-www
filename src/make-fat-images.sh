#!/bin/sh

echo This uses the 'fat' command-line tool to build the FAT
echo filesystem images for the static files and templates.

FAT=$(which fat)
if [ ! -x "${FAT}" ]; then
  echo I couldn\'t find the 'fat' command-line tool.
  echo Try running 'opam install fat-filesystem'
  exit 1
fi
rm -f files.img tmpl.img
${FAT} create files.img
${FAT} create tmpl.img
cd ../files
${FAT} add ../src/files.img *
cd ../tmpl
${FAT} add ../src/tmpl.img *
echo Created 'files.img'
echo Created 'tmpl.img'

