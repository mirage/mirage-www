---
updated: 2014-08-12
author:
  name: Mindy Preston
  uri: https://github.com/yomimono
  email: mindy.preston@cl.cam.ac.uk
subject: Contributing to MirageOS
permalink: contributing
---

MirageOS welcomes contributions from anyone interested in the project.  If you are planning a large contribution, be it a piece of documentation, a patch to the software, a new driver, or something else, please do send a note to [the MirageOS development mailing list](http://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel) describing your planned contribution - you may discover that other contributors are willing to help.

More information on being in touch with other MirageOS contributors [is available](/community).

## Reporting Issues

Issues (e.g. bugs in the software, unclear documentation, missing functionality) are best reported on the main [MirageOS repository](http://www.github.com/mirage/mirage/issues) at GitHub, unless the issue is clearly contained in, and only relevant to, another specific repository.

When reporting an issue, please try to include any information you think may be relevant, including

* a link to the source code you're building with MirageOS
* relevant version info, e.g. your opam version (`opam --version`) and your MirageOS version (`mirage --version`), and your operating system and version.
* if applicable, a terminal log representing how you trigger the issue, and what happens when the problem is occurring
* a description of any way you may have tried to solve the issue, or gather more information about it

## Submitting Changes

MirageOS uses the [pull request](https://help.github.com/articles/using-pull-requests) facility of GitHub to manage patches for both code and documentation.  Patches should be as self-contained as possible, with one patch corresponding to (at most) one bugfix or feature.  For large changes, please coordinate with other contributors via the [mailing list](https://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel).

The mechanics for submitting a pull request are as follows:

* [Set up a free GitHub account](https://github.com/signup).
* [Fork](https://help.github.com/articles/fork-a-repo) the repository to which you intend to commit your code.  For example, a patch to the TCP/IP stack in MirageOS should fork [mirage-tcpip](http://www.github.com/mirage/mirage-tcpip), and a patch correcting a problem with the website's documentation should fork [mirage-www](http://www.github.com/mirage/mirage-www).
* Make a [branch](https://github.com/blog/1377-create-and-delete-branches) with a descriptive name for the changes you plan to make.
* If you are making code changes, you may wish to point `opam` to your local repository for that code with `opam pin`.  [More details on using opam when developing are available at the `opam` site.](https://opam.ocaml.org/doc/Packaging.html)
* Make changes in your local repository.  [Here are some simple guidelines on commit messages.](https://wiki.gnome.org/Git/CommitMessages)
* When you're satisfied that your changes are ready to be submitted, [push your changes to GitHub](https://help.github.com/articles/pushing-to-a-remote).
* The web view for your repository should now have a button labeled `submit pull request`, where you can view the summary of your change and request that it be merged into the main repository.
* Keep an eye out for notifications on your pull request!  By default, GitHub will email you when other contributors have questions or comments that they'd like to discuss with you before merging your changes.

