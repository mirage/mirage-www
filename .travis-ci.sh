# OPAM packages needed to build tests.
OPAM_PACKAGES="mirage mirage-net cow mirage-fs mirari cohttp"

# Install OCaml and OPAM PPAs
echo "yes" | sudo add-apt-repository ppa:avsm/ppa-testing
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
export OPAMVERBOSE=1

opam init 

case "$OCAML_VERSION" in
4.00.1)
  opam switch 4.00.1
  ;;
*)
  # system compiler is 4.01.0
  ;;
esac

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
fi

opam install $mirage_pkg ${OPAM_PACKAGES}

eval `opam config -env`
./default_build.sh
