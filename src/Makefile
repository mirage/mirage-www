.PHONY: crunch kv_ro run_crunch run_kv_ro

all: run_kv_ro
	@ :

crunch: _build/unix-socket/crunch_server.bin *.ml
	@ :

kv_ro: _build/unix-socket/kv_ro_server.bin *.ml
	@ :

run_crunch: crunch
	sudo ./_build/unix-socket/crunch_server.bin

run_kv_ro: crunch
	sudo mir-run -b unix-socket -kv_ro static:../files -kv_ro templates:../tmpl ./_build/unix-socket/kv_ro_server.bin

filesystem_static.ml: ../files/*
	mir-crunch -name "static" ../files > $@

filesystem_templates.ml: ../tmpl/*
	mir-crunch -name "templates" ../tmpl > $@

_build/unix-socket/crunch_server.bin: filesystem_static.ml filesystem_templates.ml
	mir-build -j 5 unix-socket/crunch_server.bin

_build/unix-socket/kv_ro_server.bin:
	mir-build -j 5 unix-socket/kv_ro_server.bin

.PHONY:clean
clean:
	rm -f filesystem_static.ml filesystem_templates.ml
	rm -f myocamlbuild.ml
	ocamlbuild -clean
