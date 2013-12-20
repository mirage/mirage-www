### Maintenance

The `opam upgrade` command will refresh all your remote repositories, and recompile any outdated libraries. You will need to run this once per compiler installed, so switch between them.

If you run into any problems with OPAM, then first ask on the Mirage [mailing list](/about), or report a [bug](http://github.com/OCamlPro/opam/issues). It is safe to delete `~/.opam` and just start the installation again if you run into an unrecoverable situation, as OPAM doesn't use any files outside of that space.

### Development

There are two kinds of OPAM remote repositories: `stable` released versions of packages that have version numbers, and `dev` packages that are retrieved via git or darcs (and eventually, other version control systems too).

To develop a new package, create a new `opam-repository` Git repo.

```
$ mkdir opam-repository
$ cd opam-repository
$ git init
$ mkdir packages
$ opam remote add mypkg .
```

This will configure your local checkout as a development remote, and OPAM will pull from it on every update. Each package lives in a directory named with the version, such as `packages/foo.0.1`, and requires three files inside it:

* `foo.0.1/url` : the URL to the distribution file or git directory
* `foo.0.1/opam` : the package commands to install and uninstall it
* `foo.0.1/descr` : a description of the library or application

It's easiest to copy the files from an existing package and modify them to your needs (and read the [doc](http://opam.ocamlpro.org) for more information). Once you're done, add and commit the files, issue an `opam update`, and the new package should be available for installation or upgrade.
