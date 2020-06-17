FROM ocurrent/opam:alpine-3.10-ocaml-4.10
RUN cd ~/opam-repository && git pull origin master && git reset --hard 2d5e10966e239ee1ce2c4d8135bf7c40e5d25e92 && opam update
RUN opam depext -ui mirage
RUN mkdir -p /home/opam/www/src
WORKDIR /home/opam/www/src
COPY --chown=opam:root src/config.ml /home/opam/www/src/
ARG TARGET=unix
ARG EXTRA_FLAGS=
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS
RUN make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS
RUN opam config exec -- make
RUN if [ $TARGET = hvt ]; then sudo cp www.$TARGET /unikernel.$TARGET; fi
