MirageOS targets different backends: micro-kernels for the Xen hypervisor, Unix
executables and Javascript programs. The recent inclusion of the Javascript
backend makes many C bindings unsuitable. In order to push backend incompatibilities
closer to the application level, it is necessary to either reimplement the C
bindings in Javascript or OCaml, or remove them completely. This is particularly
important for the standard library.

##The `Str` module has to go!

`Str` provides regular expressions in a non-reentrant, non-functional fashion.
While the OCaml distribution provides it in `otherlibs`, it is installed by
default and so widely used, and implemented under the hood via a C library.
Regular expressions are used in several places in MirageOS, mainly for small
operations (splitting, getting an offset, etc.), and so having a portable
fallback written in pure OCaml would be very useful.

There are several possible ways to replace the `Str` module, each with its own
set of perks and drawbacks:
* Use a backend-neutral regexp library which "translates" to either `Str`
  or `Pcre` for the Xen and Unix backends or Javascript native regexps for
  the Javascript backend. This solution may be hard to maintain, especially if a
  fourth backend is to be included. Moreover each regexp library uses a slightly
  different convention for regexps (e.g. see the
  [magic](http://vimdoc.sourceforge.net/htmldoc/pattern.html#/magic) option in
  vim) which means that a lot of translation code might be needed.
* Do string processing without regexps (using `String.index` and the likes).
  This solution is portable and potentially efficient. However, the potential
  efficiency comes from a low-level way of doing things.
* Use an OCaml regexp library without C bindings. We expected such a library to
  be slower than `Str` and needed an estimation of performance cost in order to
  assess the practicality of the solution.

##Benchmarking `Str`

There is a purely OCaml regexp library readily available, called `Regexp` and
developed by Claude Marché from the LRI laboratory. You can find the
documentation and the source on the associated
[webpage](http://www.lri.fr/~marche/regexp/). After getting rid of mutexes
(which, in MirageOS, are of no use, because of the `Lwt` based
concurrency), we benchmarked it against `Str`. We also included the popular
`Pcre` (Perl Compatible Regular Expression) library that is widely used.

The benchmark (available [on github](http://github.com/raphael-proust/regexp-benchmark.git))
is really simple and measures three different factors:
* regexp construction: the transformation of a string (or another representation
  available to the programmer) into the internal representation of regexps used
  by the library
* regexp usage: the execution of operations using regexps
* string size: the length of the string being matched

MirageOS uses regexp in a specific pattern: a limited number of regexp
constructions with a potentially high number of invocation (e.g. HTTP header parsing).
The size of the strings on which regexps are used may vary.  Because of this pattern,
our benchmark does not take regexp construction overhead into account.

Here are the execution times of approximately 35000 string matching operations
on strings of 20 to 60 bytes long.

<img src="/graphics/all_1_1000_10.png"/>

Quite surprisingly for the string matching operation, the C based `Str` module
is less efficient than the pure OCaml `Regexp`. The `Pcre` results were even worse
than `Str`. Why?

###A simple library for a simple task

The `Regexp` library is lightweight, and so far faster than its C based
counterparts. One of the features `Regexp` lacks is "group capture": the ability
to refer to blocks of a previously matched string. In `Pcre` it is possible to
explicitly and selectively turn group capturing off via special syntax,
instead of the regular parentheses. `Str` does not offer  this, and thus
imposes the runtime cost of capture even when not necessary. In other words, the
slowdown/group capturing "is not a feature, it's a bug!"

###The MirageOS Regexp library

With the introduction of `Regexp` into the tree, the libraries available to MirageOS
applications are now `Str`-free and safer to use across multiple backends. The main
drawback is a slight increase in verbosity of some parts of the code.
Benchmarking the substitution operation is also necessary to assess the
performance gain/loss (which we will do shortly).

In addition to cosmetic and speed considerations, it is important to consider the
portability increase: MirageOS's standard library is [Node.js](http://nodejs.org) compatible,
a feature we will explore shortly!
