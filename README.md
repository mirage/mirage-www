## MirageOS Website

[![Build Status](https://travis-ci.org/mirage/mirage-www.png?branch=master)](https://travis-ci.org/mirage/mirage-www)

This repository contains the MirageOS public website, <https://mirage.io/>.

It provides information about the project as well as the blog and wiki.

It also serves as a good first self-hosting test case.


To build this website, first use `make prepare`
You can then build the mirage application in the src/ directory:
```
cd src && mirage configure && make
```

For unikernel configuration options, use `mirage configure --help` in `src`.

To update, send a pull request. When successfully merged, the Travis CI scripts,
fetched from <https://github.com/ocaml/ocaml-travisci-skeleton/>, will cause the
generated Xen unikernel to be committed back to the
<https://github.com/mirage/mirage-www-deployment> repo.
