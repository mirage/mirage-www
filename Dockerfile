FROM ocurrent/opam:alpine-3.10-ocaml-4.10
RUN cd ~/opam-repository && git pull origin master && git reset --hard 4b28c8f5d2de25c3704f04126b926da5511767f8 && opam update
RUN opam depext -ui mirage
RUN mkdir -p /home/opam/www/src
WORKDIR /home/opam/www/src
COPY --chown=opam:root src/config.ml /home/opam/www/src/

RUN opam info mirage

# pin conduit
ARG CONDUIT=https://github.com/samoht/ocaml-conduit.git#simplify-conduit-mirage
RUN opam pin -n add conduit.2.3.0 $CONDUIT
RUN opam pin -n add conduit-lwt.2.3.0 $CONDUIT
RUN opam pin -n add conduit-mirage.2.3.0 $CONDUIT

# pin cohttp
ARG COHTTP=https://github.com/samoht/ocaml-cohttp.git#32b8b8e9c9b95c4c0758377704489e138fc44367
RUN opam pin -n add cohttp.2.3.0 $COHTTP
RUN opam pin -n add cohttp-lwt.2.3.0 $COHTTP
RUN opam pin -n add cohttp-mirage.2.3.0 $COHTTP

# pin mirage
ARG MIRAGE=https://github.com/samoht/mirage.git#conduit-2.3
RUN opam pin -n add mirage.3.10.1 $MIRAGE

ARG TARGET=unix
ARG EXTRA_FLAGS=
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS
RUN make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS
RUN opam config exec -- make
RUN if [ $TARGET = hvt ]; then sudo cp www.$TARGET /unikernel.$TARGET; fi
