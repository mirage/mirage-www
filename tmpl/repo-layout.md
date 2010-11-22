The Mirage [source code](http://github.com/avsm/mirage) consists of a few major pieces. This post explains where you can find bits of the source code if you want to browse around or start hacking on it.

!!Toolchain

There are quite a few diverse backends available (from operating system to web browser), and so Mirage bundles all the compilers necessary in the `tools` directory. This also makes it easy to apply local patches to specialise them for our use.  Right now the compilers included are:

* `tools/ocaml`: main OCaml bytecode and native code compiler.
* `tools/ocamljs`: the OCaml to Javascript compiler written by [Jake Donham](https://github.com/jaked/ocamljs)
* `tools/ocaml-libs`: a collection of useful libraries used by the host-toolchain (for example in the `camlp4` syntax extensions to parse Unicode or XML).
* `tools/ocamldsort`: a dependency sorter for OCaml source files, written by [Dimitri Ara](http://dimitri.mutu.net/ocaml.html)
* `tools/mpl`: The Meta Packet Language (MPL) specification compiler, uses to convert Internet packet formats into OCaml parsing and construction modules.

There are also a few glorious hacks in that directory which may or may not continue to exist as things stabilise:

* `tools/ocamlpack`: takes multiple source OCaml files and outputs a single module file with them all included as sub-modules. This is needed due to limitations in the built-in binary `-pack` option; it doesn't work with `ocamljs` or `ocamldoc`.
* `tools/crunch`: reads in a directory of files, and outputs an OCaml "filesystem" module that serves those files directly from memory. Very useful when the storage sub-system isn't working yet, or (as with this website) everything can be served from RAM easily anyway.

Finally, `tools/mir` has the actual build utility for Mirage that hides away all the complexity of building across the various backends. `mir -help` gives you a list of command line options. Note that, for now, you have to invoke build from within the `mirage.git` repository as there no installation support until things stabilise more.

!!Libraries

to complete
