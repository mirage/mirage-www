Mirage targets different backends: micro-kernels for the Xen hypervisor, Unix
executables and Javascript programs. The recent inclusion of the Javascript
backend makes C bindings unsuitable. In order to push backend incompatibilities
closer to the application level, it is necessary to either reimplement the C
bindings in Javascript or remove them completely. This is really important for
the standard library.

##The `Str` module has to go!

`Str` provides regular expressions in a non reentrant, non functional fashion.
While OCaml have it in otherlibs, in Mirage it is included in stdlib. Regular
expressions are used in several places in Mirage's code, mainly for small
operations (splitting, getting an offset, etc.).

There are several possible ways to replace the `Str` module each with its own
set of perks and drawbacks:
* Use a backend neutral regexp library which "translates" to either `Str`
  or `Pcre` for the Xen and Unix backends or Javascript native regexps for
  the Javascript backend. This solution may be hard to maintain, especially if a
  fourth backend is to be included. Moreover each regexp library uses a slightly
  different convention for regexps (e.g. see the
  [`magic`](http://vimdoc.sourceforge.net/htmldoc/pattern.html#/magic) option in
  vim) which means that a lot of translation code might be needed.
* Do string processing without regexps (using `String.index` and the likes).
  This solution is portable and potentially efficient. However, the potential
  efficiency comes from a low level way of doing things.
* Use an OCaml regexp library without C bindings. We expected such a library to
  be slower than `Str` and needed an estimation of performance cost in order to
  assess the practicality of the solution.


##Benchmarking `Str`

There is a purely OCaml regexp library readily available. It's call `Regexp` and
was developed by Claude Marché from the LRI laboratory. You can find the
documentation and the source on the associated
[webpage](http://www.lri.fr/~marche/regexp/). After getting rid of mutexes
(which, in Mirage's case, are of no use, because of the `Lwt` based
concurrency), we benchmarked it against `Str`. We also included `Pcre`.

The setting (which one can get
[on github](git@github.com:raphael-proust/Regexp-benchmark.git)) is really
simple and allow to measure three different factors:
* regexp construction: the transformation of a string (or another representation
  available to the programmer) into the internal representation of regexps used
  by the library
* regexp usage: the execution of operations using regexps
* string size: the length of the string being matched

Mirage's use of regexp follows a specific pattern: very limited number of regexp
constructions with a potentially high number of usage. The size of the strings
on which regexps are used may vary. Because of this pattern, our benchmark does
not take regexp construction into account.

Here are the execution times of approximately 35000 string matching operations
on strings of 20 to 60 bytes long.

<img src="/graphics/all_1_1000_10.png"/>

Quite surprisingly for the string matching operation, the C based `Str` module
is less efficient than the pure OCaml `Regexp`. `Pcre`'s result were even worse
than `Str`.


##A simple library for a simple task

To be fair, the `Regexp` library has a very limited interface and the use case
benchmarked here only makes use of these limited capabilities. Simply put, the
benchmark is designed to measure efficiency of tasks that are actually used in
Mirage. On more complicated tasks, other libraries may be more suited, but in
Mirage's use, `Regexp` offers enough possibilities.

The `Regexp` library is lightweight and thus faster than its C based
counterparts. One of the feature `Regexp` lacks is 'group capture': the ability
to refer to blocks of previously matched string. In `Pcre` it is possible to
explicitly and selectively turn group capturing off by using `(?:`/pattern/`)`
instead of the regular parentheses. `Str` does not offer this possibility, thus
imposing the runtime cost of capture even when not necessary. In other words,
"it's not a feature, it's a bug!"


##Mirage's new regexps

The libraries available to Mirage applications are `Str`-free. The main
drawback is a slight increase in verbosity of some parts of the code.
Benchmarking the substitution operation is also necessary to asses the
performance gain/loss (which we will do shortly). Additionally to cosmetic and
speed considerations, it is important to consider the portability increase:
Mirage's standard library is Node compatible!


