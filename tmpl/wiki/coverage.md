Coverage testing of code in OCaml is best handled via the [bisect](http://bisect.x9c.fr) library.
It operates by recompiling code via a camlp4 extension to instrument tests ,
and then check how much of the main library was exercised by the test cases.
This can be automated into the existing GitHub workflows by using the
[coveralls.io](http://coveralls.io] web service, using the
[ocveralls](https://github.com/sagotch/ocveralls) OCaml library.

As a reference, two libraries that use it are
[mirage-block-volume](https://github.com/mirage/mirage-block-volume) and
[shared-block-ring](https://github.com/mirage/shared-block-ring).  The
following procedure works pretty well:

1. `make coverage`, and load result in web-browser
2. spot a big chunk of obvious red (danger, danger, danger)
3. (thinking carefully about what could go wrong) devise an interesting test to
   stress the red bits (obviously you could cover it with a 'noddy' test but
   there is probably no point)
4. `make coverage`, reload in browser and see the red go green!

To setup this workflow, register with `coveralls.io` with [this sort of
commit](https://github.com/mirage/shared-block-ring/commit/67b9f3100be8e4e9732dd79b7c1cc5352a61d478).
It sets up the master branch in development mode, links against bisect, and
doesnt check in the OASIS autogen files.  The `travis.yml` files runs the
Travis CI skeleton scripts and then calls [ocveralls](https://github.com/sagotch/ocveralls)
to upload the results to coveralls.io.

Some miscellaneous notes:

* The repositories above also have a `make release` step which removes bisect and
  generates a tarball that is suitable for release.

* The game is made even more addictive when the coveralls badge changes colour;
  for example see: <https://coveralls.io/r/mirage/mirage-block-volume?branch=master>

* Here is an example bisect report of the source code: <http://dave.recoil.org/tmp/report/file0000.html>

If you can think of a nicer way to integrate this into OASIS then get in touch
on the [mailing list](/community), since using `sed` on the `_oasis` file is a bit of a hack.

