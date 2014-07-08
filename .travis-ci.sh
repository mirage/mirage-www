# OPAM packages needed to build tests.
OPAM_PACKAGES="mirage cow ssl cowabloga ipaddr lwt cstruct sexplib crunch"

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
echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

opam init git://github.com/ocaml/opam-repository >/dev/null 2>&1
# opam pin mirage git://github.com/avsm/mirage
#opam pin cowabloga git://github.com/mirage/cowabloga
opam install ${OPAM_PACKAGES}
eval `opam config env`
cp .travis-www.ml src/config.ml
cd src
mirage --version
mirage configure --unix
make depend
make
make clean
mirage configure --xen
make depend
make
cd ..

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
    cp ../src/mir-www.xen ../src/config.ml xen/$TRAVIS_COMMIT
    bzip2 -9 xen/$TRAVIS_COMMIT/mir-www.xen
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
fi
