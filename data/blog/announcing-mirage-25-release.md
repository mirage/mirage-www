---
updated: 2015-06-26 16:00
authors:
- name: Amir Chaudhry
  uri: http://amirchaudhry.com
  email: amirmc@gmail.com
- name: Thomas Gazagnaire
  uri: http://gazagnaire.org
  email: thomas@gazagnaire.org
subject: MirageOS v2.5 with full TLS support
permalink: announcing-mirage-25-release
---

Today we're announcing the new release of MirageOS v2.5, which includes
first-class support for SSL/TLS in the MirageOS configuration language. We
introduced the pure OCaml implementation of
[transport layer security (TLS)][tls] last summer and have been working since
then to improve the integration and create a robust framework.  The recent
releases allow developers to easily build and deploy secure unikernel services
and we've also incorporated numerous bug-fixes and major stability
improvements (especially in the network stack).  The full list of changes is
available on the [releases][] page and the [breaking API changes][breaking]
now have their own page.

Over the coming week, we'll share more about the TLS stack by diving into the
results of the [Bitcoin Piñata][pinata-post], describing a new workflow for
building secure static sites, and discussing insights on entropy in
virtualised environments.

In the rest of this post, we'll cover why OCaml-TLS matters (and link to some
tools), mention our new domain name, and mention our security advisory
process.

### Why OCaml-TLS matters ###

The last year has seen a slew of security flaws, which are even reaching the
mainstream news.  This history of flaws are often the result of implementation
errors and stem from the underlying challenges of interpreting ambiguous
specifications, the complexities of large APIs and code bases, and the use of
unsafe programming practices.  Re-engineering security-critical software
allows the opportunity to use modern approaches to prevent these recurring
issues. In a [separate post][tls-benefits], we cover some of the benefits of
re-engineering TLS in OCaml. 

#### TLS Unix Tools ####

To make it even easier to start benefiting from OCaml-TLS, we've also made a
collection of [TLS unix tools][tls-unix].  These are designed to make it
really easy to use a good portion of the stack without having to use Xen. For
example, Unix `tlstunnel` is being used on <https://realworldocaml.org>. If
you have `stunnel` or `stud` in use somewhere, then replacing it with the 
`tlstunnel` binary is an easy way to try things out.  Please do give this a go
and send us feedback!


### openmirage.org -> mirage.io ###

We've also switched our domain over to **<https://mirage.io>**, which is a
unikernel running the full stack. We've been discussing this transition for a
while on our [fortnightly calls][calls] and have actually been running this
unikernel in parallel for a while. Setting things up this way has allowed us
to stress test things in the wild and we've made big improvements to the
networking stack as a result.

We now have end-to-end deployments for our secure-site unikernels, which is
largely automated -- going from `git push` all the way to live site. You can
get an idea of the workflows we have set up by looking over the following
links:

- [Automated unikernel deployment](http://amirchaudhry.com/heroku-for-unikernels-pt1) -- Description of the end-to-end flow for one of our sites.
- [mirage-www-deployment repo](https://github.com/mirage/mirage-www-deployment) -- The repo from which we pull the site you're currently reading! You might find the scripts useful.


### Security disclosure process ###

Since we're incorporating more security features, it's important to consider
the process of disclosing issues to us.  Many bugs can be reported as usual on
our [issue tracker][issues] but if you think you've discovered a
**security vulnerability**, the best way to inform us is described on a new
page at **<https://mirage.io/security>**.


### Get started! ###

As usual, MirageOS v2.5 and the its ever-growing collection of
libraries is packaged with the [OPAM][] package
manager, so look over the [installation instructions][install]
and run `opam install mirage` to get the command-line
tool. To update from a previously installed version of MirageOS,
simply use the normal workflow to upgrade your packages by using `opam
update -u` (you should do this regularly to benefit from ongoing fixes).
If you're looking for inspiration, you can check out the examples on
[mirage-skeleton][] or ask on the [mailing list][lists]. Please do be aware
that existing `config.ml` files using
the `conduit` and `http` constructors might need to be updated -- we've made a
page of [backward incompatible changes][breaking] to explain what you need to
do.

We would love to hear your feedback on this release, either on our
[issue tracker][issues] or [our mailing lists][lists]!


[tls]: /blog/introducing-ocaml-tls
[pinata]: http://ownme.ipredator.se
[releases]: /releases
[breaking]: /wiki/breaking-changes
[pinata-post]: /blog/announcing-bitcoin-pinata
[tls-benefits]: /blog/why-ocaml-tls
[tls-unix]: /wiki/tls-unix
[calls]: /wiki/#Weekly-calls-and-release-notes
[OPAM]: https://opam.ocaml.org
[mirage-skeleton]: https://github.com/mirage/mirage-skeleton
[install]: /wiki/install
[issues]: https://github.com/mirage/mirage/issues
[lists]: /community

