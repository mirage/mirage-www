FROM ocurrent/opam:alpine-3.10-ocaml-4.09
RUN opam depext -ui mirage
RUN mkdir -p /home/opam/www/src
WORKDIR /home/opam/www/src
COPY --chown=opam:root src/config.ml /home/opam/www/src/
ARG TARGET=unix
RUN opam config exec -- mirage configure -t $TARGET
RUN make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -t $TARGET
RUN opam config exec -- make
RUN if [ $TARGET = hvt ]; then sudo cp www.$TARGET /unikernel.$TARGET; fi
