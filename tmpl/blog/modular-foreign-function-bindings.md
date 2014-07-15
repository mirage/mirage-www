## Modular foreign function bindings

One of the most frequent questions about MirageOS from developers is
"do I really need to write all my code in OCaml"?  There are, of
course, very good reasons to build the core system in pure OCaml: the
module system permits reusing algorithmic abstractions at scale, and
OCaml's static type checking makes it possible to enforce lightweight
invariants across interfaces.  However, it's ultimately necessary to
support interfacing to existing code, and this blog post will describe
what we're doing to make this possible this without sacrificing the
security benefits afforded by unikernels.

A MirageOS application works by abstracting the *logic* of the
application from the details of *platform* that it is compiled for.
The `mirage` CLI tool parses a configuration file that represents the
desired hardware target, which can be a Unix binary or a specialized
Xen guest OS.  Our foreign function interface design elaborates on
these design principles by separating the *description* of the C
foreign functions from how we *link* to that code.  For instance, a
Unix unikernel could use the normal `ld.so` to connect to a shared
library, while in Xen we would need to interface to that C library
through some other mechanism (for instance, a separate VM could be
spawned to run the untrusted OpenSSL code).  If you're curious about
how this works, this blog post is for you!

### Introducing ctypes

[ocaml-ctypes][ocaml-ctypes] ("ctypes" for short) is a library for
gluing together OCaml code and C code without writing any C.  This
post introduces the ctypes library with a couple of simple examples,
and outlines how OCaml's module system makes it possible to write
high-level bindings to C that are independent of any particular
linking mechanism.

### Hello, C

Binding a C function using ctypes involves two steps.

* First, construct an OCaml value that represents the type of the function
* Second, use the type representation and the function name to resolve and bind the function

For example, here's a binding to C's `puts` function, which prints a string to
standard output and returns the number of characters written:

```ocaml
let puts = foreign "puts" (string @-> returning int)
```

After the call to `foreign` the bound function is available to OCaml
immediately.  Here's a call to `puts` from the interactive top level:

```ocaml
# puts "Hello, world";;
Hello, world
- : int = 13
```

### &lt;Hello-C/&gt;

Now that we've had a taste of ctypes, let's look at a more realistic
example: a program that defines bindings to the [expat][expat] XML
parsing library, then uses them to display the structure of an XML
document.

We'll start by describing the types used by expat.  Since ctypes
represents C types as OCaml values, each of the types we need becomes
a value binding in our OCaml program.  The parser object involves an
incomplete (abstract) struct definition and a typedef for a pointer to
a struct:

```C
struct xml_ParserStruct;
typedef xml_ParserStruct *xml_Parser;
```

In ctypes these become calls to the `structure` and `ptr` functions:

```ocaml
let parser_struct : [`XML_ParserStruct] structure typ = structure "xml_ParserStruct"
let xml_Parser = ptr parser_struct
```

Next, we'll use the type representations to bind some functions.  The
[`XML_ParserCreate`](http://www.xml.com/pub/a/1999/09/expat/reference.html#parsercreate)
and
[`XML_ParserFree`](http://www.xml.com/pub/a/1999/09/expat/reference.html#parserfree)
functions construct and destroy parser objects.  As with `puts`, each
function binding involves a simple call to `foreign`:

```ocaml
let parser_create = foreign "XML_ParserCreate"
  (ptr void @-> returning xml_Parser)
let parser_free = foreign "XML_ParserFree"
  (xml_Parser @-> returning void)
```

Expat operates primarily through callbacks: when start and end elements are
encountered the parser invokes user-registered functions, passing the tag names
and attributes (along with a piece of user data):

```C
typedef void (*start_handler)(void *, char *, char **);
typedef void (*end_handler)(void *, char *);
```

In ctypes function pointer types are built using the `funptr` function:

```ocaml
let start_handler =
  funptr (ptr void @-> string @-> ptr string @-> returning void)
let end_handler =
  funptr (ptr void @-> string @-> returning void)
```

We can use the `start_handler` and `end_handler` type representations to bind
[`XML_SetElementHandler`](http://www.xml.com/pub/a/1999/09/expat/reference.html#elementhandler), the callback-registration function:

```ocaml
let set_element_handler = foreign "XML_SetElementHandler"
  (xml_Parser @-> start_handler @-> end_handler @-> returning void)
```

The type that OCaml infers for `set_element_handler` reveals that the function
accepts regular OCaml functions as arguments, since the argument types are
normal OCaml function types:

```ocaml
val set_element_handler :
  [ `XML_ParserStruct ] structure ptr ->
  (unit ptr -> string -> string ptr -> unit) ->
  (unit ptr -> string -> unit) -> unit
```

There's one remaining function to bind, then we're ready to use the
library.  The
[`XML_Parse`](http://www.xml.com/pub/a/1999/09/expat/reference.html#parse)
function performs the actual parsing, invoking the callbacks when tags
are encountered:

```ocaml
let parse = foreign "XML_Parse"
  (xml_Parser @-> string @-> int @-> int @-> returning int)
```

As before, all the functions that we've bound are available for use
immediately.  We'll start by using them to define a more idiomatic OCaml entry
point to the library.  The `parse_string` function accepts the start and end
callbacks as labelled arguments, along with a string to parse:

```ocaml
let parse_string ~start_handler ~end_handler s =
  let p = parser_create null in
  let () = set_element_handler p start_handler end_handler in
  let _ = parse p s (String.length s) 1 in
  parser_free p
```

Using `parse_string` we can write a program that prints out the names of each
element in an XML document, indented according to nesting depth:

```ocaml
let depth = ref 0

let start_handler _ name _ =
  Printf.printf "%*s%s\n" (!depth * 3) "" name;
  incr depth

let end_handler _ _ =
  decr depth

let () =
  parse_string ~start_handler ~end_handler
    Batteries.(Enum.fold (^) "" (File.lines_of Sys.argv.(1)))
```

Here's the program in action:

```bash
$ ocamlfind opt -package batteries,ctypes.foreign expat_example.ml \
  -linkpkg -cclib -lexpat -o expat_example
$ wget -q http://openmirage.org/blog/atom.xml -O /dev/stdout \
  | ./expat_example /dev/stdin
feed
   id
   title
   subtitle
   rights
   updated
   link
   link
   contributor
      email
      uri
      name
[...]
```

Since this is just a high-level overview we've passed over a number of
details.  The interested reader can find a more comprehensive introduction to
using ctypes in [Chapter 19 of Real World OCaml][rwo-19].

### Dynamic vs static

Up to this point we've been using a single function, `foreign`, to
make C functions available to OCaml.  Although `foreign` is simple to
use, there's quite a lot going on behind the scenes.  The two
arguments to `foreign` are used to dynamically construct an OCaml
function value that wraps the C function: the name is used to resolve
the code for the C function, and the type representation is used to
construct a call frame appropriate to the C types invovled and to the
underlying platform.

The dynamic nature of `foreign` that makes it convenient for
interactive use, also makes it unsuitable for some environments.
There are three main drawbacks:

* Binding functions dynamically involves a certain loss of *safety*:
  since C libraries typically don't maintain information about the
  types of the functions they contain, there's no way to check whether
  the type representation passed to `foreign` matches the actual type of
  the C function.

* Dynamically constructing calls introduces a certain *interpretative
  overhead*.  (The overhead is actually much less than might be supposed,
  since much of the work can be done when the function is bound rather than
  when the call is made, and `foreign` has been used to bind C functions in
  [performance-sensitive applications][tgls] without problems.)

* The implementation of `foreign` uses a low-level library, [libffi][libffi],
  to deal with calling conventions across platforms.  While libffi is mature
  and widely supported, it's not appropriate for use in every environment.
  For example, introducing such a (relatively) large and complex library into
  Mirage would compromise many of the benefits of writing the rest of the
  system in OCaml.

Happily, there's a solution at hand.  As the introduction hints, `foreign` is
one of a number of binding strategies, and OCaml's module system makes it easy
to defer the choice of which strategy to use when writing the actual code.
Placing the `expat` bindings in a functor (parameterised module) makes it
possible to abstract over the linking strategy:

```ocaml
module Bindings(F : FOREIGN) =
struct
  let parser_create = F.foreign "XML_ParserCreate"
    (ptr void @-> returning xml_Parser)
  let parser_free = F.foreign "XML_ParserFree"
    (xml_Parser @-> returning void)
  let set_element_handler = F.foreign "XML_SetElementHandler"
    (xml_Parser @-> start_handler @-> end_handler @-> returning void)
  let parse = F.foreign "XML_Parse"
    (xml_Parser @-> string @-> int @-> int @-> returning int)
end
```

The `Bindings` module accepts a single parameter of type `FOREIGN`, which
encodes the binding strategy to use.  Instantiating `Bindings` with a module
containing the `foreign` function used above recovers the
dynamically-constructed bindings that we've been using so far.  However, there
are now other possibilities available.  In particular, we can instantiate
`Bindings` with code generators that output code to expose the bound functions
to OCaml.  The actual instantiation is hidden behind a couple of convenient
functions, `write_c` and `write_ml`, which accept `Bindings` as a parameter:

```ocaml
write_c formatter ~prefix:"expat" ~bindings:(module Bindings)
write_ml formatter ~prefix:"expat" ~bindings:(module Bindings)
```

Generating code in this way eliminates the concerns associated with
constructing calls dynamically:

* The C compiler checks the types of the generated calls against the C
  headers (the API), so the safety concerns associated with linking
  directly against the C library binaries (the ABI) don't apply.
 
* There's no interpretative overhead, since the generated code is
  (statically) compiled.

* The dependency on libffi disappears altogether.

How easy is it in practice to switch between dynamic and static
binding strategies?  It turns out that it's quite straightforward,
even for code that was originally written without parameterisation.
Bindings written using early releases of ctypes used the dynamic
strategy exclusively, since dynamic binding was then the only option
available.  The commit logs for projects that switched over to static
generation and linking (e.g. [1][lz4-cstubs-switch],
[2][async-ssl-cstubs-switch]) when it became available show that
moving to the new approach involved only straightforward and localised
changes.

### Local vs remote

Generating code is safer than constructing calls dynamically, since it
allows the C compiler to check the types of function calls against
declarations.  However, there are some safety problems that even C's
type checking doesn't detect.  For instance, the following call is
type correct (given suitable definitions of `p` and `q`), but is
likely to misbehave at run time:

```C
memcpy(p, q, SIZE_MAX)
```

In contrast, code written purely in OCaml detects and prevents
attempts to write beyond the bounds of allocated objects:

```ocaml
# StringLabels.blit ~src ~dst ~src_pos:0 ~dst_pos:0 ~len:max_int;;
Exception: Invalid_argument "String.blit".
```

It seems a shame to weaken OCaml's safety guarantees by linking in C
code that can potentially write to any region of memory, but what is
the alternative?

One possibility is to use [privilege separation][privsep] to separate
trusted OCaml code from untrusted C functions.  The modular design of
ctypes means that privilege separation can be treated as one more
linking strategy: we can run C code in an entirely separate process
(or for Mirage/Xen, in a separate virtual machine), and instantiate
`Bindings` with a strategy that forwards calls to the process using
standard inter-process communication.  (The remote calling strategy is
not supported in the [current release][ctypes-0.3.2] of ctypes, but
it's scheduled for a future version.  As with the switch from dynamic
to static bindings, we anticipate that updating existing bindings to
use cross-process calls will be straightforward.)

### Further examples

Although ctypes is a fairly new library, it's already in use in a
number of projects across a variety of domains: [graphics][tgls],
[multimedia][tsdl], [compression][lz4], [cryptography][sodium],
[security][sasl], [geospatial data][gdal], [communication][nanomsg],
and many others.  Further resources (documentation, forums, etc.) are
available via the [home page][ocaml-ctypes].

[mirage-ocaml]: http://openmirage.org/wiki/technical-background#WhyOCaml
[libffi]: https://sourceware.org/libffi/
[tgls]: http://erratique.ch/software/tgls
[ocaml-ctypes]: https://github.com/ocamllabs/ocaml-ctypes
[lz4-cstubs-switch]: https://github.com/whitequark/ocaml-lz4/commit/acc257ea1
[async-ssl]: https://github.com/janestreet/async_ssl
[async-ssl-cstubs-switch]: https://github.com/janestreet/async_ssl/commit/ab5ea6f55e
[tsdl]: http://erratique.ch/software/tsdl
[lz4]: https://github.com/whitequark/ocaml-lz4
[sodium]: https://github.com/dsheets/ocaml-sodium
[sasl]: https://github.com/nojb/ocaml-gsasl
[gdal]: https://github.com/hcarty/ocaml-gdal
[nanomsg]: http://github.com/rgrinberg/onanomsg
[privsep]: http://en.wikipedia.org/wiki/Privilege_separation
[ctypes-0.3.2]: https://github.com/ocamllabs/ocaml-ctypes/releases/tag/0.3.2
[expat]: http://www.libexpat.org/
[rwo-19]: https://realworldocaml.org/v1/en/html/foreign-function-interface.html
