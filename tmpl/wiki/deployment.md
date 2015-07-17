This live MirageOS website is written as a MirageOS application itself, with the
source code on [mirage/mirage-www](https://github.com/mirage/mirage-www) on
GitHub. Our workflow is such that we can send a
[pull request](https://github.com/mirage/mirage-www/pulls?direction=desc&page=1&sort=created&state=closed)
to update the website, and have a fully standalone Xen kernel committed into the
binary
[mirage/mirage-www-deployment](https://github.com/mirage/mirage-www-deployment)
repository.

This all works by installing a fresh MirageOS installation for each change
committed to the website, and rebuilding the entire website unikernel from scratch
(a process that takes around 5-7 minutes without any parallel building). We use
the free [Travis Continuous Integration](http://travis-ci.org) for automating
all of this, so that we don't need to host any servers to go from pull request
to a deployed cloud.

### Getting started with Travis

First, log into [Travis](http://travis-ci.com) and sign in via your GitHub
credentials. Click on the [Accounts](https://travis-ci.org/profile) button on
the top-right and you should see a list of the all the GitHub repositories that
you have access to. Just click the _On_ switch for the one you want to start
testing (in our case,
[mirage/mirage-www](https://github.com/mirage/mirage-www)). Nothing will
actually happen until the next code push or pull request goes to that
repository. Behind the scenes, the _On_ button that you clicked use the GitHub
APIs to turn on the Travis post-commit hook for your repository.

Create a `.travis.yml` file in your main repository that references the
[OCaml Travis CI Skeleton](https://github.com/ocaml/ocaml-travisci-skeleton)
[Mirage](https://github.com/ocaml/ocaml-travisci-skeleton/blob/master/.travis-mirage.sh)
script. Travis doesn't have native support for OCaml, but it isn't really needed
since we can just use the `C` mode and write our own shell scripts. The `env`
variables define a matrix of the different combinations of MirageOS backends
that we want to test. Just remove variations that you don't care about to avoid
wasting Travis' CPU time (open source projects are supported on a fair-use basis
by them).

Here's the first part of the `.travis.yml` used by
[mirage/mirage-www](https://github.com/mirage/mirage-www):

```
language: c
install: wget https://raw.githubusercontent.com/ocaml/ocaml-travisci-skeleton/master/.travis-mirage.sh
script: bash -ex .travis-mirage.sh
env:
  matrix:
  - OCAML_VERSION=4.02 MIRAGE_BACKEND=unix MIRAGE_NET=socket
  - OCAML_VERSION=4.02 MIRAGE_BACKEND=unix MIRAGE_NET=direct
  - OCAML_VERSION=4.02 MIRAGE_BACKEND=xen  DEPLOY=1 XENIMG="openmirage.org"
    IP="46.43.42.147" NETMASK="255.255.255.128" GATEWAYS="46.43.42.129"
    TLS=0 HOST="openmirage.org" REDIRECT="https://mirage.io"
    UPDATE_GCC_BINUTILS=1
  - OCAML_VERSION=4.02 MIRAGE_BACKEND=xen DEPLOY=1 XENIMG="mirage.io"
    IP="46.43.42.146" NETMASK="255.255.255.128" GATEWAYS="46.43.42.129"
    TLS=1 HOST="mirage.io" SECRETS=fat
    UPDATE_GCC_BINUTILS=1
```

This is followed by a set of `global` `secure` keys that we'll come back to
below when talking about deployment.

Every pull request and commit to the
[mirage-www](https://github.com/mirage/mirage-www) repository then triggers a
set of test builds via [Travis CI](https://travis-ci.org/), ensuring we
consistently build for the range of MirageOS backends. Each build runs in a
separate VM provisioned by the Travis infrastructure, invoking the
[.travis-mirage.sh](https://github.com/ocaml/ocaml-travisci-skeleton/blob/master/.travis-mirage.sh)
script, which begins:

```
# If a fork of these scripts is specified, use that GitHub user instead
fork_user=${FORK_USER:-ocaml}

# If a branch of these scripts is specified, use that branch instead of 'master'
fork_branch=${FORK_BRANCH:-master}

### Bootstrap

set -uex

get() {
  wget https://raw.githubusercontent.com/${fork_user}/ocaml-travisci-skeleton/${fork_branch}/$@
}

TMP_BUILD=$(mktemp -d)
cd ${TMP_BUILD}

get .travis-ocaml.sh
sh .travis-ocaml.sh
export OPAMYES=1
eval $(opam config env)
```

This fetches and executes the
[.travis-ocaml.sh](https://github.com/ocaml/ocaml-travisci-skeleton/blob/master/.travis-ocaml.sh)
script which installs the requested version of OCaml, various native packages we
will need, and the latest OPAM from an Ubuntu package repository we maintain.

The script then continues:

```
opam install ocamlfind

get yorick.mli
get yorick.ml
get travis_mirage.ml

ocamlc.opt yorick.mli
ocamlfind ocamlc -c yorick.ml

ocamlfind ocamlc -o travis-mirage -package unix -linkpkg yorick.cmo travis_mirage.ml
cd -

${TMP_BUILD}/travis-mirage
```

This fetches a helper library,
[`yorick`](https://github.com/ocaml/ocaml-travisci-skeleton/blob/master/yorick.mli),
and builds it; and finally fetches, builds and executes
[travis_mirage.ml](https://github.com/ocaml/ocaml-travisci-skeleton/blob/master/travis_mirage.ml)
with the environment variables defined in the
[.travis.yml](https://github.com/mirage/mirage-www/.travis.yml) file. This piece
of OCaml sets the environment to use OPAM, installs any pins requested by
setting the variable `PINS` in the `.travis.yml` file (none in this case), and
then executes the following commands:

```
eval $(opam config env)

opam update -u
opam install mirage
MODE=$MIRAGE_BACKEND make configure
make build
```

The build is configured via variables set in the `.travis.yml`
(`MIRAGE_BACKEND`, `IP`, `NETMASK` and so on), and then executed.

### Pushing to the deployment repository

Builds occur for all the specified backends. One of these is the Xen backend,
the output of which must be pushed to the
[deployment repository](https://github.com/mirage/mirage-www-deployment) if the
build was triggered by a commit (not a pull request) to the main `mirage-www`
repo. To do so securely we use Travis'
[support for encrypted environment variables](http://about.travis-ci.org/docs/user/encryption-keys/).
The basic workflow is that you encrypt key/value pairs using a public key that
they publish per GitHub repository. Once registered, this is made available as a
decrypted environment variable within the Travis worker. You can use this to
transmit API keys or other authentication data that you need to commit to the
`travis.yml` file, but obviously can't leave on a public repository for the
world to see.

The small hitch with this whole scheme is that there's a very small limit
of about 90 bytes or so for the size of each individual environment variable
that's exported, and so you can't just stash an SSH private key in there.
Instead, it needs to be Base64 encoded, split it up into multiple environment
variables of the right size, and then reassembled within the Travis VM.  Rather
than deal with importable shell scripts between MacOS X and Linux, we provide
a small `travis-senv` command-line tool to make this easier.

To use it, just `opam install travis-senv` and follow the instructions on the
[README at the homepage](https://github.com/avsm/travis-senv). The final
fragment of the
[travis_mirage.ml](https://github.com/mirage/mirage-www/blob/master/travis_mirage.ml),
having defined the following predicates:

```
let is_deploy = getenv_default "DEPLOY" "false" |> fuzzy_bool_of_string
let is_travis_pr =
  getenv_default "TRAVIS_PULL_REQUEST" "false" |> fuzzy_bool_of_string
let have_secret =
  getenv_default "XSECRET_default_0" "false" |> fuzzy_bool_of_string
let is_xen =
  getenv_default "MIRAGE_BACKEND" "" |> function "xen" -> true | _ -> false
let travis_branch = getenv_default "TRAVIS_BRANCH" ""
```

...shows this in action:

```
if is_deploy && is_xen && have_secret && (not is_travis_pr) &&
   travis_branch = "master"
then begin
  let ssh_config = "Host mir-deploy github.com
                   \  Hostname github.com
                   \  StrictHostKeyChecking no
                   \  CheckHostIP no
                   \  UserKnownHostsFile=/dev/null"
  in
  export "XENIMG" "mir-${XENIMG:-$TRAVIS_REPO_SLUG#mirage/mirage-}.xen";
  export "MIRDIR" "${MIRDIR:-src}";
  export "DEPLOYD" "${TRAVIS_REPO_SLUG#*/}-deployment";

  (* setup ssh *)
  ?|  "opam install travis-senv";
  ?|  "mkdir -p ~/.ssh";
  ?|  "travis-senv decrypt > ~/.ssh/id_dsa";
  ?|  "chmod 600 ~/.ssh/id_dsa";
  ?|~ "echo '%s' > ~/.ssh/config" ssh_config;
  (* configure git for github *)
  ?|  "git config --global user.email 'travis@openmirage.org'";
  ?|  "git config --global user.name 'Travis the Build Bot'";
  ?|  "git config --global push.default simple";
  (* clone deployment repo *)
  ?|  "git clone git@mir-deploy:${TRAVIS_REPO_SLUG}-deployment";
  (* remove and recreate any existing image for this commit *)
  ?|  "rm -rf $DEPLOYD/xen/$TRAVIS_COMMIT";
  ?|  "mkdir -p $DEPLOYD/xen/$TRAVIS_COMMIT";
  ?|  "cp $MIRDIR/$XENIMG $MIRDIR/config.ml $DEPLOYD/xen/$TRAVIS_COMMIT";
  ?|  "bzip2 -9 $DEPLOYD/xen/$TRAVIS_COMMIT/$XENIMG";
  ?|  "echo $TRAVIS_COMMIT > $DEPLOYD/xen/latest";
  (* commit and push changes *)
  ?|  "cd $DEPLOYD &&\
       \ git add xen/$TRAVIS_COMMIT xen/latest &&\
       \ git commit -m \"adding $TRAVIS_COMMIT for $MIRAGE_BACKEND\" &&\
       \ git push"
end
```

(The `?|` and `?|~` operators are defined in [`yorick.ml`](https://github.com/ocaml/ocaml-travisci-skeleton/blob/master/yorick.ml) and act simply as shell
invocations piping `stdin`/`stdout`/`stderr` in the usual way, with
success/failure tests on the status of each invoked command.)

While this fragment is a bit longer than the rest, it's actually rather
straightforward. We install `travis-senv` and use it to retrieve our SSH
deployment key (which is stored encrypted in the `.travis.yml` file, and can
only be decrypted by the Travis infrastructure). Once that's installed, we
initialise `git` and clone the deployment repository. We then compress our
output unikernel, update the `xen/latest` pointer to refer to the new unikernel,
commit everything, and push the results back.

### Updating the live website

The live website runs on a Xen machine which has a crontab entry in dom0 that
polls the
[mirage/mirage-www-deployment](http://github.com/mirage/mirage-www-deployment)
repository for new content via `git pull`. When new content __is__ obtained, a
Git [`post-merge.hook`](http://git-scm.com/docs/githooks#_post_merge) is invoked
which
[stops the current unikernel and boots the newly updated latest version](https://github.com/mirage/mirage-www-deployment/blob/master/scripts/post-merge.hook).
This machine doesn't need to have any of the MirageOS tools installed, and if
there's an error in an updated website, we can simply revert back to a previous
as previous binary revisions of the site remain in the deployment repository.

The same approach could be used to deploy to Heroku, Rackspace or EC2 instead of
a custom Xen host; we'll cover this in future updates.

*(Note: This article is based on a similar blog post for general OCaml use
 available
 [here](http://anil.recoil.org/2013/10/06/travis-secure-ssh-integration.html).)*
