This live Mirage website is written as a Mirage application itself, with the
source code on [mirage/mirage](https://github.com/mirage/mirage) on GitHub.
Our workflow is such that we can send a [pull
request](https://github.com/mirage/mirage-www/pulls?direction=desc&page=1&sort=created&state=closed)
to update the website, and have a fully standalone Xen kernel committed into
the binary [mirage/mirage-www-deployment](https://github.com/mirage/mirage-www-deployment) repository.

This all works by installing a fresh Mirage installation for each change
committed to the website, and rebuilding the entire website kernel from scratch
(a process that takes around 5-7 minutes without any parallel building).  We 
use the free [Travis Continuous Integration](http://travis-ci.org) for automating
all of this, so that we don't need to host any servers to go from pull request
to a deployed cloud.

### Getting started with Travis

First, log into [Travis](http://travis-ci.com) and sign in via your GitHub
credentials.  Click on the [Accounts](https://travis-ci.org/profile) button on
the top-right and you should see a list of the all the GitHub repositories that
you have access to.  Just click the <i>On</i> switch for the one you want to
start testing (in our case,
[mirage/mirage-www](https://github.com/mirage/mirage-www)).  Nothing will
actually happen until the next code push or pull request goes to that
repository.  Behind the scenes, the <i>On</i> button that you clicked use the
GitHub APIs to turn on the Travis post-commit hook for your repository.

Create a `.travis.yml` file in your main repository (see below or [this file](https://github.com/mirage/mirage-www/blob/master/.travis-ci.sh)).  Travis doesn't have native support for OCaml, but it isn't really needed since we can just use the `C` mode and write our own shell scripts.  The `env` variables define a matrix of the different combinations of Mirage backends that we want to test.  Just remove variations that you don't care about to avoid wasting Travis' CPU time (open source projects are supported on a fair-use basis by them).

Here's the `.travis.yml` that used by [mirage/mirage-www](https://github.com/mirage/mirage-www):

```
language: c
script: bash -ex .travis-ci.sh
env:
  matrix:
  - OCAML_VERSION=4.01.0 MIRAGE_BACKEND=unix OPAM_VERSION=1.1.0
  - OCAML_VERSION=4.01.0 MIRAGE_BACKEND=xen  OPAM_VERSION=1.1.0 DEPLOY=1
  - OCAML_VERSION=4.00.1 MIRAGE_BACKEND=unix OPAM_VERSION=1.1.0
  - OCAML_VERSION=4.00.1 MIRAGE_BACKEND=xen  OPAM_VERSION=1.1.0
```

There are some other keys called `secure` below that we'll come back to when talking about deployment.

Now you just need the `.travis-ci.sh` shell to run the actual tests.  Travis
provides an Ubuntu Precise/i386 VM that is destroyed after every test run, so
we need to initialize it with the OCaml and OPAM binary packages.  Since you
often want to test different versions of all of these, we have a series of
stable Ubuntu PPAs that have OCaml 3.12.1, 4.00.1, and 4.01.0 available, along
with OPAM 1.0 and 1.1.

Out of these, Mirage requires at least OPAM 1.1 and an
OCaml greater than 4.00.1, so we'll pick just those PPAs for our tests.  The
[travis-ci.sh](https://github.com/mirage/mirage-www/blob/master/.travis-ci.sh)
from the repository starts like this:

```
# OPAM packages needed to build tests.
OPAM_PACKAGES="mirage"

case "$OCAML_VERSION,$OPAM_VERSION" in
3.12.1,1.0.0) ppa=avsm/ocaml312+opam10 ;;
3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
*) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
esac

echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
export OPAMVERBOSE=1
opam init
eval `opam config env`
opam install ${OPAM_PACKAGES}
```

This script is called with the environment variables defined above in the
Travis Yaml file.  We start off by defining the OPAM packages that are a
prerequisite to build the website (just the Mirage tool for our website).
After that, the script figures out the PPA repository it needs, and installs
OCaml and OPAM from binary packages.  The OPAM variables configure it to run
non-interactively and verbosely, since Travis captures all the log output
and records it as a debugging aid.

### Building the website in Travis

The script then continues onto building the website using the usual `mirage`
commands:

```
cp .travis-www.ml src/config.ml
cd src
mirage --version
mirage configure --unix
make
make clean
mirage configure --xen
```

The test script also has to compile in the configuration of the live website
(which has a static IPv4 address).  Once that's copied in, we build a Unix
version (just to check it builds) and then recompile to the Xen version (which
we want to save and deploy).

Now just do a push to your repository (a commit adding the Travis files above
will do), and you will soon see the [web
interface](https://travis-ci.org/mirage/mirage-www) update.  For example,
here's the [output of a recent website
build](https://travis-ci.org/mirage/mirage-www/builds/15968275) that fixed some
of the documentation content.

Travis isn't just for code pushes though; as of mid-2013 it can also [test pull
requests](http://about.travis-ci.org/blog/announcing-pull-request-support/).
This is an incredibly useful feature for Mirage since it means that you can
experimentally propose changes without having to try all the different
backends.  You don't need to do anything special to activate it: whenever
someone issues a pull request, Travis will merge it locally and trigger the
test runs just as if the code had been pushed directly.

### Pushing to the deployment repository

Now that we've built the kernel in Travis, we need to push the final kernel
to the [mirage/mirage-www-deployment](https://github.com/mirage/mirage-www-deployment)
repository.
One nice feature that Travis has is [support for
encrypted environment variables](http://about.travis-ci.org/docs/user/encryption-keys/).
The basic workflow is that you encrypt
key/value pairs using a public key that they publish per GitHub repository.
Once registered, this is made available as a decrypted environment variable
within the Travis worker.  You can use this to transmit API keys or other
authentication data that you need to commit to the `travis.yml` file, but
obviously can't leave on a public repository for the world to see.

The small hitch with this whole scheme is that there's a very small limit
of about 90 bytes or so for the size of each individual environment variable
that's exported, and so you can't just stash an SSH private key in there.
Instead, it needs to be Base64 encoded, split it up into multiple environment
variables of the right size, and then reassembled within the Travis VM.  Rather
than deal with importable shell scripts between MacOS X and Linux, we provide
a small `travis-senv` command-line tool to make this easier.

To use it, just `opam install travis-senv` and follow the instructions on the
[README at the homepage](https://github.com/avsm/travis-senv). The final
fragment of the [travis-ci.sh](https://github.com/mirage/mirage-www/blob/master/.travis-ci.sh#L41)
shows this in action for the website.

```
if [ "$DEPLOY" = "1" -a "$TRAVIS_PULL_REQUEST" = "false" ]; then
  # get the secure key out for deployment
  opam install travis-senv
  mkdir -p ~/.ssh
  SSH_DEPLOY_KEY=~/.ssh/id_dsa
  travis-senv decrypt > $SSH_DEPLOY_KEY
  chmod 600 $SSH_DEPLOY_KEY
  echo "Host mirdeploy github.com" >> ~/.ssh/config
  echo "   Hostname github.com" >> ~/.ssh/config
  echo "   StrictHostKeyChecking no" >> ~/.ssh/config
  echo "   CheckHostIP no" >> ~/.ssh/config
  echo "   UserKnownHostsFile=/dev/null" >> ~/.ssh/config
  git config --global user.email "travis@openmirage.org"
  git config --global user.name "Travis the Build Bot"
  git clone git@mirdeploy:mirage/mirage-www-deployment
  case "$MIRAGE_BACKEND" in
  xen)
    cd mirage-www-deployment
    rm -rf xen/$TRAVIS_COMMIT
    mkdir -p xen/$TRAVIS_COMMIT
    cp ../src/mir-main.xen ../src/config.ml xen/$TRAVIS_COMMIT
    bzip2 -9 xen/$TRAVIS_COMMIT/mir-main.xen
    git pull --rebase
    echo $TRAVIS_COMMIT > xen/latest
    git add xen/$TRAVIS_COMMIT xen/latest
    ;;
  *)
    echo unsupported deploy mode: $MIRAGE_BACKEND
    exit 1
    ;;
  esac
  git commit -m "adding $TRAVIS_COMMIT for $MIRAGE_BACKEND"
  git push
```

While this fragment is a bit longer than the rest, it's all rather
straightforward.  We install `travis-senv` and use it to retrieve
our SSH deployment key (which is stored encrypted in the `.travis.yml`
file, and can only be decrypted by the Travis infrastructure).
Once that's installed, we initialize `git` and clone the deployment
repository.  We then compress our output kernel and commit it to
the repository along with the configuration data.

### Updating the live website

The live website runs on a Xen machine hosted in Cambridge, and
this simply polls the [mirage/mirage-www-deployment](http://github.com/mirage/mirage-www-deployment)
repository for new pushes, and updates to the latest version in
that repository when one appears.  This machine doesn't need to
have any of the Mirage tools installed, and if there's an error in
an updated website, we can simply revert back to a previous changeset
of the deployed site.

The same approach could be used to deploy to Heroku, Rackspace or EC2 instead of
a custom Xen host; we'll cover this in future updates.

*(Note: This article is based on a similar blog post for general OCaml use available [here](http://anil.recoil.org/2013/10/06/travis-secure-ssh-integration.html))*
