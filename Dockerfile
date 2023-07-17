FROM ocaml/opam:debian-12-ocaml-4.14
RUN sudo apt-get update && sudo apt-get install autoconf automake -y --no-install-recommends
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam && cd ~/opam-repository && git pull origin master && git reset --hard 297ab9ebb38254eee222f5bb4365ae80baa9caa1 && opam update
RUN opam pin git+https://github.com/tmattio/opam-tailwindcss#a4c0ee9b9a80d44c4a953b07dc29e4aa065adf57
RUN opam repo add mirage-dev git+https://github.com/mirage/mirage-dev.git#842c55556ffd0950d21141d6ab99e52a8d88a50f
RUN opam install mirage
COPY --chown=opam:root mirage/config.ml /home/opam/www/mirage/
COPY --chown=opam:root mirageio.opam /home/opam/www/
ARG TARGET=unix
ARG EXTRA_FLAGS=
RUN opam exec -- mirage configure -f mirage/config.ml -t $TARGET $EXTRA_FLAGS
RUN opam exec -- make depend
COPY --chown=opam:root . /home/opam/www
RUN opam exec -- mirage configure -f mirage/config.ml -t $TARGET $EXTRA_FLAGS
RUN opam exec -- dune build mirage/ --profile release
RUN if [ $TARGET = hvt ]; then sudo cp mirage/dist/www.$TARGET /unikernel.$TARGET; fi
