FROM ocaml/opam:debian-12-ocaml-4.14
RUN sudo apt-get update && sudo apt-get install autoconf automake -y --no-install-recommends
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN cd ~/opam-repository && git pull origin master && git reset --hard 9f03f078ed1fa7e5361257dc4c77c9cbcee76c19
RUN opam update
RUN opam install 'mirage>=4.5.0'
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
