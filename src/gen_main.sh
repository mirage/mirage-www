#!/bin/sh -e

mir-crunch -name "static" ../files > filesystem_static.ml
mir-crunch -name "templates" ../tmpl > filesystem_templates.ml
echo open Filesystem_static > main.ml
echo open Filesystem_templates >> main.ml
echo open Server >> main.ml
echo open Dispatch >> main.ml
echo "let _ = OS.Main.run (main ())" >> main.ml
