FROM ocaml/opam:ubuntu-ocaml-4.11
RUN sudo apt install -y m4 pkg-config
RUN cd ~/opam-repository && git pull origin master && git reset --hard ee6c1009d891d8b1ee4d68cee90cd66c2ab4fb3b && opam update
RUN opam repo add mirage-dev https://github.com/mirage/mirage-dev.git#dcc79014e10006b1b84fe5ed45c5ef067dc4caf7
RUN opam depext -ui mirage
RUN mkdir -p /home/opam/www/src
WORKDIR /home/opam/www/src
COPY --chown=opam:root src/config.ml /home/opam/www/src/
ARG TARGET=unix
ARG EXTRA_FLAGS=
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS
RUN opam config exec -- make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS
RUN opam config exec -- mirage build
RUN if [ $TARGET = hvt ]; then sudo cp dist/www.$TARGET /unikernel.$TARGET; fi
