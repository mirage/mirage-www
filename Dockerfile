FROM ocaml/opam:ubuntu-ocaml-4.11
RUN sudo apt install -y m4 pkg-config
RUN cd ~/opam-repository && git pull origin master && git reset --hard ef82e5bc09e89868e9393bc8ded218b02517876e && opam update
RUN opam repo add mirage-dev https://github.com/mirage/mirage-dev.git#713b884b36a58579515b2ea55ec057f6fe310a52
RUN opam depext -ui mirage
RUN mkdir -p /home/opam/www/src
WORKDIR /home/opam/www/src
COPY --chown=opam:root src/config.ml /home/opam/www/src/
ARG TARGET=unix
ARG EXTRA_FLAGS=
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS --extra-repo https://github.com/mirage/opam-overlays.git#aa30403f107034500e5f697ddfc6e954117fc059
RUN opam config exec -- make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -t $TARGET $EXTRA_FLAGS --extra-repo https://github.com/mirage/opam-overlays.git#aa30403f107034500e5f697ddfc6e954117fc059
RUN opam config exec -- mirage build
RUN if [ $TARGET = hvt ]; then sudo cp dist/www.$TARGET /unikernel.$TARGET; fi
