*This is the fourth in a series of posts that introduce new libraries for a pure OCaml implementation of TLS.
You might like to begin with the [introduction][tls-intro].*

[asn1-combinators][asn1-combinators] is a library that allows one to express
[ASN.1][asn-wiki] grammars directly in OCaml, manipulate them as first-class entities,
combine them with one of several ASN encoding rules and use the result to parse
or serialize values.

It is the parsing and serialization backend for our [X.509][ocaml-x509]
certificate library, which in turn provides certificate handling for
[ocaml-tls][ocaml-tls].
We wrote about the X.509 certificate handling [yesterday][x509-intro].

[asn1-combinators]: https://github.com/mirleft/ocaml-asn1-combinators
[ocaml-x509]: https://github.com/mirleft/ocaml-x509
[ocaml-tls]: https://github.com/mirleft/ocaml-tls
[asn-wiki]: https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One

### What is ASN.1, really? ###

[ASN.1][asn-wiki] (Abstract Syntax Notation, version one) is a way to describe
on-the-wire representation of messages. It is split into two components: a way
to describe the content of a message, i.e. a notation for its abstract syntax,
and a series of standard encoding rules that define the exact byte
representations of those syntaxes. It is defined in ITU-T standards X.680-X.683
and X.690-X.695.

The notation itself contains primitive grammar elements, such as `BIT STRING` or
`GeneralizedTime`, and constructs that allow for creation of compound grammars
from other grammars, like `SEQUENCE`. The notation is probably best introduced
through a real-world example:

```
-- Simple name bindings
UniqueIdentifier ::= BIT STRING

-- Products
Validity ::= SEQUENCE {
  notBefore Time,
  notAfter  Time
}

-- Sums
Time ::= CHOICE {
  utcTime     UTCTime,
  generalTime GeneralizedTime
}
```

(Example from [RFC 5280][rfc5280-sample], the RFC that describes X.509
certificates which heavily rely on ASN.)

The first definition shows that we can introduce an alias for any existing ASN
grammar fragment, in this case the primitive `BIT STRING`. The second and third
definitions are, at least morally, a product and a sum.

At their very core, ASN grammars look roughly like algebraic data types, with a
range of pre-defined primitive grammar fragments like `BIT STRING`, `INTEGER`,
`NULL`, `BOOLEAN` or even `GeneralizedTime`, and a number of combining
constructs that can be understood as denoting sums and products.

Definitions such as the above are arranged into named modules. The standard even
provides for some abstractive capabilities: initially just a macro facility, and
later a form of parameterized interfaces.

To facilitate actual message transfer, a grammar needs to be coupled with an
encoding. By far the most relevant ones are Basic Encoding Rules (BER) and
Distinguished Encoding Rules (DER), although other encodings exist.

BER and DER are tag-length-value (TLV) encodings, meaning that every value is
encoded as a triplet containing a tag that gives the interpretation of its
contents, a length field, and the actual contents which can in turn contain
other TLV triplets.

Let's drop the time from the example above, as time encoding is a little
involved, and assume a simpler version for a moment:

```
Pair ::= SEQUENCE {
  car Value,
  cdr Value
}

Value ::= CHOICE {
  v_str UTF8String,
  v_int INTEGER
}
```

Then two possible BER encodings of a `Pair` `("foo", 42)` are:

```
  30         - SEQUENCE            30         - SEQUENCE
  08         - length              0c         - length
  [ 0c       - UTF8String          [ 2c       - UTF8String, compound
    03       - length                07       - length
    [ 66     - 'f'                   [ 0c     - UTF8String
      6f     - 'o'                     01     - length
      6f ]   - 'o'                     [ 66 ] - 'f'
    02       - INTEGER                 0c     - UTF8String
    01       - length                  02     - length
    [ 2a ] ] - 42                      [ 6f   - 'o'
                                         6f ] - 'o'
                                     02       - INTEGER
                                     01       - length
                                     [ 2a ] ] - 42
```

The left one is also the only valid DER encoding of this value: BER allows
certain freedoms in encoding, while DER is just a BER subset without those
freedoms. The property of DER that any value has exactly one encoding is useful,
for example, when trying to digitally sign a value.

If this piqued your curiosity about ASN, you might want to take a detour and
check out this [excellent writeup][asn-laymans-guide].

[asn-wiki]: https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One
[rfc5280-sample]: http://tools.ietf.org/html/rfc5280#appendix-A.2
[asn-laymans-guide]: http://luca.ntop.org/Teaching/Appunti/asn1.html

### A bit of history ###

The description above paints a picture of a technology a little like [Google's
Protocol Buffers][protobuf] or [Apache Thrift][thrift]: a way to declaratively
specify the structure of a set of values and derive parsers and serializers,
with the addition of multiple concrete representations.

But the devil is in the detail. For instance, the examples above intentionally
gloss over the fact that often concrete tag values [leak][x509-generalname] into
the grammar specifications for various disambiguation reasons. And ASN has more
than 10 different [string types][string-type-list], most of which use
long-obsolete character encodings. Not to mention that the full standard is
close to 200 pages of relatively dense language and quite difficult to
follow. In general, ASN seems to have too many features for the relatively
simple task it is solving, and its specification has evolved over decades, apparently
trying to address various other semi-related problems, such as providing a
general [Interface Description Language][asn-ioc].

Which is to say, ASN is *probably* not what you are looking for. So why
implement it?

Developed in the context of the telecom industry around 30 years ago, modified
several times after that and apparently suffering from a lack of a coherent
goal, by the early 90s ASN was still probably the only universal, machine- and
architecture-independent external data representation.

So it came easily to hand around the time RSA Security started publishing its
series of [PKCS][pkcs-wiki] standards, aimed at the standardization of
cryptographic material exchange. RSA keys and digital signatures are often
exchanged ASN-encoded.

At roughly the same time, ITU-T started publishing the [X.500][x500-wiki] series
of standards which aimed to provide a comprehensive directory service. Much of
this work ended up as LDAP, but one little bit stands out in particular: the
[X.509][x509-wiki] PKI certificate.

So a few years later, when Netscape tried to build an authenticated and
confidential layer to tunnel HTTP through, they based it on -- amongst other
things -- X.509 certificates. Their work went through several revisions as SSL
and was finally standardized as TLS. Modern TLS still requires X.509.

Thus, even though TLS uses ASN only for encoding certificates (and the odd PKCS1
signature), every implementation needs to know how to deal with ASN. In fact,
many other general cryptographic libraries also need to deal with ASN, as various PKCS
standards mandate ASN as the encoding for exchange of cryptographic material.

[protobuf]: https://code.google.com/p/protobuf/
[thrift]: https://thrift.apache.org/
[x509-generalname]: http://tools.ietf.org/html/rfc5280#page-128
[string-type-list]: http://www.obj-sys.com/asn1tutorial/node128.html
[asn-ioc]: https://en.wikipedia.org/wiki/Information_Object_Class_(ASN.1)
[pkcs-wiki]: https://en.wikipedia.org/wiki/PKCS
[x500-wiki]: https://en.wikipedia.org/wiki/X.500
[x509-wiki]: https://en.wikipedia.org/wiki/X.509

### The grammar of the grammar ###

As its name implies, ASN was meant to be used with a specialized compiler. ASN
is really a standard for *writing down* abstract syntaxes, and ASN compilers
provided with the target encoding will generate code in your programming
language of choice that, when invoked, parses to or serializes from ASN.

As long as your programming language of choice is C, C++, Java or C#, obviously
-- there doesn't seem to be one freely available that targets OCaml. In any case, generating code for such a high-level language feels wrong somehow. In
its effort to be language-neutral, ASN needs to deal with things like modules,
abstraction and composition. At this point, most functional programmers reading
this are screaming: "I *already* have a language that can deal with modules,
abstraction and composition perfectly well!"

So we're left with implementing ASN in OCaml.

One strategy is to provide utility functions for parsing elements of ASN and
simply invoke them in the appropriate order, as imposed by the target grammar.
This amounts to hand-writing the parser and is what TLS libraries in C
typically do.

As of release 1.3.7, [PolarSSL][polar-src] includes ~7,500 lines of rather
beautifully written C, that implement a specialized parser for dealing with
X.509. OpenSSL's [libcrypto][openssl-src] contains ~50,000 lines of C in its
['asn1'][openssl-src-asn], ['x509'][openssl-src-x509] and
['x509v3'][openssl-src-x509v3] directories, and primarily deals with X.509
specifically as required by TLS.

In both cases, low-level control flow is intertwined with the parsing logic and,
above the ASN parsing level, the code that deals with interpreting the ASN
structure is not particularly concise.
It is certainly a far cry from the (relatively)
simple grammar description ASN itself provides.

Since in BER every value fully describes itself, another strategy is to parse
the input stream without reference to the grammar. This produces a value that
belongs to the general type of all ASN-encoded trees, after which we need to
process the *structure* according to the grammar. This is similar to a common
treatment of JSON or XML, where one decouples parsing of bytes from the
higher-level concerns about the actual structure contained therein. The problem
here is that either the downstream client of such a parser needs to constantly
re-check whether the parts of the structure it's interacting with are really
formed according to the grammar (probably leading to a tedium of
pattern-matches), or we have to turn around and solve the parsing problem
*again*, mapping the uni-typed contents of a message to the actual, statically
known structure we require the message to have.

Surely we can do better?

[polar-src]: https://github.com/polarssl/polarssl/tree/development/library
[openssl-src]: https://github.com/openssl/openssl
[openssl-src-asn]: https://github.com/openssl/openssl/tree/e3ba6a5f834f24aa5ffe9bc1849e3410c87388d5/crypto/asn1
[openssl-src-x509]: https://github.com/openssl/openssl/tree/e3ba6a5f834f24aa5ffe9bc1849e3410c87388d5/crypto/x509
[openssl-src-x509v3]: https://github.com/openssl/openssl/tree/e3ba6a5f834f24aa5ffe9bc1849e3410c87388d5/crypto/x509v3

### LAMBDA: The Ultimate Declarative ###

Again, ASN is a language with a number of built-in primitives, a few combining
constructs, (recursive) name-binding and a module system. Our target language is
a language with a perfectly good module system and it can certainly express
combining constructs. It includes an abstraction mechanism arguably far simpler
and easier to use than those of ASN, namely, functions. And the OCaml compilers
can already parse OCaml sources. So why not just reuse this machinery?

The idea is familiar. Creating embedded languages for highly declarative
descriptions within narrowly defined problem spaces is the staple of functional
programming. In particular, combinatory parsing has been known, studied and
used for [decades][frost-paper].

However, we also have to diverge from traditional parser combinators in two major ways.
Firstly, a single grammar expression needs to be able to generate
different concrete parsers, corresponding to different ASN encodings. More
importantly, we desire our grammar descriptions to act **bidirectionally**,
producing both parsers and complementary deserializers.

The second point severely restricts the signatures we can support. The usual
monadic parsers are off the table because the expression such as:

```OCaml
( (pa : a t) >>= fun (a : a) ->
  (pb : b t) >>= fun (b : b) ->
  return (b, b, a) ) : (b * b * a) t
```

... "hides" parts of the parser inside the closures, especially the method of
mapping the parsed values into the output values, and can not be run "in
reverse" \[[1](#footnote-1)\].

We have a similar problem with [applicative functors][applicatives-paper]:

```OCaml
( (fun a b -> (b, b, a))
  <$> (pa : a t)
  <*> (pb : b t) ) : (b * b * a) t
```

(Given the usual `<$> : ('a -> 'b) -> 'a t -> 'b t` and `<*> : ('a -> 'b) t ->
'a t -> 'b t`.) Although the elements of ASN syntax are now exposed, the process
of going from intermediate parsing results to the result of the whole is still
not accessible.

Fortunately, due to the regular structure of ASN, we don't really *need* the
full expressive power of monadic parsing. The only occurrence of sequential
parsing is within `SEQUENCE` and related constructs, and we don't need
look-ahead. All we need to do is provide a few specialized combinators to handle
those cases -- combinators the likes of which would be derived in a
more typical setting.

So if we imagine we had a few values, like:

```OCaml
val gen_time : gen_time t
val utc_time : utc_time t
val choice   : 'a t -> 'b t -> ('a, 'b) choice t
val sequence : 'a t -> 'b t -> ('a * 'b) t
```

Assuming appropriate OCaml types `gen_time` and `utc_time` that reflect their
ASN counterparts, and a simple sum type `choice`, we could express the
`Validity` grammar above using:

```OCaml
type time = (gen_time, utc_time) choice
let time     : time t          = choice gen_time utc_time
let validity : (time * time) t = sequence time time
```

In fact, ASN maps quite well to algebraic data types. Its `SEQUENCE` corresponds
to n-ary products and `CHOICE` to sums. ASN `SET` is a lot like `SEQUENCE`,
except the elements can come in any order; and `SEQUENCE_OF` and `SET_OF` are
just lifting an `'a`-grammar into an `'a list`-grammar.

A small wrinkle is that `SEQUENCE` allows for more contextual information on its
components (so does `CHOICE` in reality, but we ignore that): elements can carry
labels (which are not used for parsing) and can be marked as optional. So
instead of working directly on the grammars, our `sequence` must work on their
annotated versions. A second wrinkle is the arity of the `sequence` combinator.

Thus we introduce the type of annotated grammars, `'a element`, which
corresponds to one `,`-delimited syntactic element in ASN's own `SEQUENCE`
grammar, and the type `'a sequence`, which describes the entire contents (`{ ...
}`) of a `SEQUENCE` definition:

```OCaml
val required : 'a t -> 'a element
val optional : 'a t -> 'a option element
val ( -@ )   : 'a element -> 'b element -> ('a * 'b) sequence
val ( @ )    : 'a element -> 'a sequence -> ('a * 'b) sequence
val sequence : 'a sequence -> 'a t
```

The following are then equivalent:

```
Triple ::= SEQUENCE {
  a INTEGER,
  b BOOLEAN,
  c BOOLEAN OPTIONAL
}
```

```OCaml
let triple : (int * (bool * bool option)) t =
  sequence (
      required int
    @ required bool
   -@ optional bool
  )
```

We can also re-introduce functions, but in a controlled manner:

```OCaml
val map : ('a -> 'b) -> ('b -> 'a) -> 'a t -> 'b t
```

Keeping in line with the general theme of bidirectionality, we require functions
to come in pairs. The deceptively called `map` could also be called `iso`, and
comes with a nice property: if the two functions are truly inverses,
the serialization process is fully reversible, and so is parsing, under
single-representation encodings (DER)!

[frost-paper]: http://comjnl.oxfordjournals.org/content/32/2/108.short
[applicatives-paper]: http://www.soi.city.ac.uk/~ross/papers/Applicative.html

### ASTs of ASNs ###

To go that last mile, we should probably also *implement* what we discussed.

Traditional parser combinators look a little like this:

```OCaml
type 'a p = string -> 'a * string

let bool : bool p = fun str -> (s.[0] <> "\000", tail_of_string str)
```

Usually, the values inhabiting the parser type are the actual parsing functions,
and their composition directly produces larger parsing functions. We would
probably need to represent them with `'a p * 'a s`, pairs of a parser and its
inverse, but the same general idea applies.

Nevertheless, we don't want to do this.
The grammars need to support more than one concrete
parser/serializer, and composing what is common between them and extracting out
what is not would probably turn into a tangled mess. That is one reason. The other is that if we encode the grammar purely as
(non-function) value, we can traverse it for various other purposes.

So we turn from what is sometimes called "shallow embedding" to "deep
embedding" and try to represent the grammar purely as an algebraic data type.

Let's try to encode the parser for bools, `boolean : bool t`:

```OCaml
type 'a t =
  | Bool
  ...

let boolean : bool t = Bool
```

Unfortunately our constructor is fully polymorphic, of type `'a. 'a t`. We can
constrain it for the users, but once we traverse it there is nothing left to
prove its intended association with booleans!

Fortunately, starting with the release of [OCaml 4.00.0][ocaml-gadt],
OCaml joined the ranks of
languages equipped with what is probably the supreme tool of deep embedding,
[GADTs][gadt-wiki]. Using them, we can do things like:

```OCaml
type _ t =
  | Bool   : bool t
  | Pair   : ('a t * 'b t) -> ('a * 'b) t
  | Choice : ('a t * 'b t) -> ('a, 'b) choice t
  ...
```

[ocaml-gadt]: http://ocaml.org/releases/4.00.1.html
[gadt-wiki]: http://en.wikipedia.org/wiki/Generalized_algebraic_data_type

In fact, this is very close to how the library is [actually][src-core]
implemented.

There is only one thing left to worry about: ASN definitions can be recursive.
We might try something like:

```OCaml
let rec list = choice null (pair int list)
```

But this won't work. Being just trees of applications, our definitions never
contain [statically constructive][rec-defn] parts -- this expression could never
terminate in a strict language.

We can get around that by wrapping grammars in `Lazy.t` (or just closures), but
this would be too awkward to use. Like many other similar libraries, we need to
provide a fixpoint combinator:

```OCaml
val fix : ('a t -> 'a t) -> 'a t
```

And get to write:

```OCaml
let list = fix @@ fun list -> choice null (pair int list)
```

This introduces a small problem. So far we simply reused binding inherited
from OCaml without ever worrying about identifiers and references, but with a
fixpoint, the grammar encodings need to be able to somehow express a cycle.

Borrowing an idea from higher-order abstract syntax, we can represent the entire
fixpoint node using exactly the function provided to define it, re-using OCaml's
own binding and identifier resolution:

```OCaml
type _ t =
  | Fix : ('a t -> 'a t) -> 'a t
  ...
```

This treatment completely sidesteps the problems with variables. We need no
binding environments or De Brujin indices, and need not care about the desired
scoping semantics. A little trade-off is that with this simple encoding it
becomes more difficult to track cycles (when traversing the AST, if we keep
applying a `Fix` node to itself while descending into it, it looks like an
infinite tree), but with a little opportunistic caching it all plays out well
\[[2](#footnote-2)\].

The [parser][src-parser] and [serializer][src-writer] proper then emerge as interpreters for
this little language of typed trees, traversing them with an input string, and
parsing it in a fully type-safe manner.

[src-core]: https://github.com/mirleft/ocaml-asn1-combinators/blob/4328bf5ee6f20ad25ff7971ee8013f79e5bfb036/src/core.ml#L19
[rec-defn]: http://caml.inria.fr/pub/docs/manual-ocaml-400/manual021.html#toc70
[src-parser]: https://github.com/mirleft/ocaml-asn1-combinators/blob/4328bf5ee6f20ad25ff7971ee8013f79e5bfb036/src/ber_der.ml#L49
[src-writer]: https://github.com/mirleft/ocaml-asn1-combinators/blob/4328bf5ee6f20ad25ff7971ee8013f79e5bfb036/src/ber_der.ml#L432

### How does it play out? ###

The entire ASN library comes down to ~1,700 lines of OCaml, with around ~1,100
more in tests, giving a mostly-complete treatment of BER and DER.

Its main use so far is in the context of the `X.509` library
(discussed [yesterday][x509-intro]). It allowed the
grammar of certificates and RSA keys, together with a number of transformations
from the raw types to more pleasant, externally facing ones, to be written in
~900 [lines][x509-asn-grammars] of OCaml. And the code looks a lot like the
actual standards the grammars were taken from -- the fragment from the beginning
of this article becomes:

```OCaml
let unique_identifier = bit_string_cs

let time =
  map (function `C1 t -> t | `C2 t -> t) (fun t -> `C2 t)
      (choice2 utc_time generalized_time)

let validity =
  sequence2
    (required ~label:"not before" time)
    (required ~label:"not after"  time)
```

We added `~label` to `'a element`-forming injections, and have:

```OCaml
val choice2 : 'a t -> 'b t -> [ `C1 of 'a | `C2 of 'b ] t
```

To get a sense of how the resulting system eases the translation of standardized
ASN grammars into working code, it is particularly instructive to compare
[these][polar-core-x509] [two][ocaml-core-x509] definitions.

Reversibility was a major simplifying factor during development. Since the
grammars are traversable, it is easy to generate their [random][asn-random]
inhabitants, encode them, parse the result and verify the reversibility still
[holds][random-tests]. This can't help convince us the parsing/serializing pair
is actually correct with respect to ASN, but it gives a simple tool to generate
large amounts of test cases and convince us that that pair is *equivalent*. A
number of hand-written cases then check the conformance to the actual ASN.

As for security, there were two concerns we were aware of. There is a history of
catastrophic [buffer overruns][windows-asn-vuln] in some ASN.1 implementations,
but -- assuming our compiler and runtime system are correct -- we are immune to
these as we are subject to bounds-checking. And
there are some documented [problems][oid-issues] with security of X.509
certificate verification due to overflows of numbers in ASN OID types, which we
explicitly guard against.

You can check our security status on our [issue tracker][tracker].

[x509-asn-grammars]: https://github.com/mirleft/ocaml-x509/blob/6c96f11a2c7911ae0b308af9b328aee38f48b270/lib/asn_grammars.ml
[polar-core-x509]: https://github.com/polarssl/polarssl/blob/b9e4e2c97a2e448090ff3fcc0f99b8f6dbc08897/library/x509_crt.c#L531
[ocaml-core-x509]: https://github.com/mirleft/ocaml-x509/blob/7bd25d152445263d7659c653e4a761222f43c75b/lib/asn_grammars.ml#L772
[asn-random]: https://github.com/mirleft/ocaml-asn1-combinators/blob/cf1a1ffb4a31d02979a6a0bca8fe58856f8907bf/src/asn_random.ml
[random-tests]: https://github.com/mirleft/ocaml-asn1-combinators/blob/cf1a1ffb4a31d02979a6a0bca8fe58856f8907bf/tests/testlib.ml#L83
[windows-asn-vuln]: https://technet.microsoft.com/en-us/library/security/ms04-007.aspx
[oid-issues]: https://www.viathinksoft.de/~daniel-marschall/asn.1/oid_facts.html
[tracker]: https://github.com/mirleft/ocaml-asn1-combinators/issues?state=open


#### Footnotes ####

  1.  <a name="footnote-1"> </a> In fact, the problem with embedding functions in
      combinator languages, and the fact that in a functional language it is not
      possible to extract information from a function other than by applying it,
      was discussed more than a decade ago. Such discussions led to the development of
      [Arrows][arrows-paper], amongst other things.

  2.  <a name="footnote-2"> </a> Actually, a version of the library used the more
      [proper][phoas-paper] encoding to be able to inject results of reducing
      referred-to parts of the AST into the referring sites directly, roughly
      like `Fix : ('r -> ('a, 'r) t) -> ('a, 'r) t`. This approach was abandoned because terms need to be polymorphic in `'r`, and this becomes
      impossible to hide from the user of the library, creating unwelcome noise.

[arrows-paper]: http://www.haskell.org/arrows/biblio.html#Hug00
[phoas-paper]: http://dl.acm.org/citation.cfm?id=1411226

****

Posts in this TLS series:
 
 - [Introducing transport layer security (TLS) in pure OCaml][tls-intro]
 - [OCaml-TLS: building the nocrypto library core][nocrypto-intro]
 - [OCaml-TLS: adventures in X.509 certificate parsing and validation][x509-intro]
 - [OCaml-TLS: ASN.1 and notation embedding][asn1-intro]
 - [OCaml-TLS: the protocol implementation and mitigations to known attacks][tls-api]

[tls-intro]: https://mirage.io/blog/introducing-ocaml-tls
[nocrypto-intro]: https://mirage.io/blog/introducing-nocrypto
[x509-intro]: https://mirage.io/blog/introducing-x509
[asn1-intro]: https://mirage.io/blog/introducing-asn1
[tls-api]: https://mirage.io/blog/ocaml-tls-api-internals-attacks-mitigation
