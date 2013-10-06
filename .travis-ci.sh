# OPAM packages needed to build tests.
OPAM_PACKAGES="mirage mirage-net cow mirage-fs mirari cohttp"

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

opam init 
eval `opam config env`

case "$MIRAGE_BACKEND" in
unix-socket)
  mirage_pkg="mirage-unix mirage-net-socket"
  ;;
unix-direct)
  mirage_pkg="mirage-unix mirage-net-direct"
  ;;
xen)
  mirage_pkg="mirage-xen"
  ;;
*)
  echo Unknown backend $MIRAGE_BACKEND
  exit 1
esac

opam install $mirage_pkg ${OPAM_PACKAGES}
cd $TRAVIS_BUILD_DIR
./default_build.sh
cp .travis-www.conf src/www.conf
make clean
./default_build.sh

if [ "$DEPLOY" = "1" ]; then
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
  cd mirage-www-deployment
  rm -rf xen/$TRAVIS_COMMIT
  mkdir -p xen/$TRAVIS_COMMIT
  cp ../src/mir-www.xen ../src/mir-www.map ../src/www.conf xen/$TRAVIS_COMMIT
  echo $TRAVIS_PULL_REQUEST > xen/$TRAVIS_COMMIT/pullreq
  bzip2 -9 xen/$TRAVIS_COMMIT/mir-www.xen
  git pull --rebase
  git add xen/$TRAVIS_COMMIT
  git commit -m "adding $TRAVIS_COMMIT"
  git push
fi
