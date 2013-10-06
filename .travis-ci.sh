# OPAM packages needed to build tests.
OPAM_PACKAGES="mirage-unix mirage cow mirage-fs mirari cohttp mirage-net"

# Install OCaml and OPAM PPAs
echo "yes" | sudo add-apt-repository ppa:avsm/ppa-testing
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
export OPAMVERBOSE=1

opam init
eval `opam config env`

# get the fake secure key out
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
git clone git@mirdeploy:mirage/mirage-www-deployment
cd mirage-www-deployment
cat README.md

opam install ${OPAM_PACKAGES}
cd $TRAVIS_BUILD_DIR
./default_build.sh
