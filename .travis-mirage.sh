## mirage setup

set -ex

## fetch+execute the OCaml/opam setup script
wget https://raw.githubusercontent.com/ocaml/ocaml-travisci-skeleton/master/.travis-ocaml.sh
sh .travis-ocaml.sh

## install mirage
export OPAMYES=1
eval $(opam config env)

opam pin add mirage-xen-minios 'https://github.com/talex5/mirage-xen-minios.git#b0.6'
opam install mirage

DEPLOY=$DEPLOY NET=$MIRAGE_NET MODE=$MIRAGE_BACKEND make configure
make build

## stash deployment build if specified
if [ "$DEPLOY" = "1" -a "$TRAVIS_PULL_REQUEST" = "false" ]; then
    opam install travis-senv
    # get the secure key out for deployment
    mkdir -p ~/.ssh
    SSH_DEPLOY_KEY=~/.ssh/id_dsa
    travis-senv decrypt > $SSH_DEPLOY_KEY
    chmod 600 $SSH_DEPLOY_KEY

    echo "Host mir-deploy github.com" >> ~/.ssh/config
    echo "   Hostname github.com" >> ~/.ssh/config
    echo "   StrictHostKeyChecking no" >> ~/.ssh/config
    echo "   CheckHostIP no" >> ~/.ssh/config
    echo "   UserKnownHostsFile=/dev/null" >> ~/.ssh/config

    git config --global user.email "travis@openmirage.org"
    git config --global user.name "Travis the Build Bot"
    git clone git@mir-deploy:${TRAVIS_REPO_SLUG}-deployment

    DEPLOYD=${TRAVIS_REPO_SLUG#mirage/}-deployment
    XENIMG=mir-${TRAVIS_REPO_SLUG#mirage/mirage-}.xen
    case "$MIRAGE_BACKEND" in
        xen)
            cd $DEPLOYD
            rm -rf xen/$TRAVIS_COMMIT
            mkdir -p xen/$TRAVIS_COMMIT
            cp ../src/$XENIMG ../src/config.ml xen/$TRAVIS_COMMIT
            bzip2 -9 xen/$TRAVIS_COMMIT/$XENIMG
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
