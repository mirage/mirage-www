FROM ocurrent/opam:alpine-3.10-ocaml-4.10
RUN cd ~/opam-repository && git pull origin master && git reset --hard b5860103f3e663a1c3e51d1bee7c4066a63698a1 && opam update
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
