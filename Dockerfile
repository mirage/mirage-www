FROM ocaml/opam:debian-11-ocaml-4.13
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam && cd ~/opam-repository && git pull origin master && git reset --hard 55dda47191d1653dd3982ff54e964cb16428e775 && opam update
RUN opam pin git+https://github.com/tmattio/opam-tailwindcss#fb0f82edd09999f7be033ab1785ba5f6b60ed8f6
RUN opam pin add git+https://github.com/mirage/mirage#8ab03cff7c811828d3e2e4473cbc0e55204652ec --with-version 4.0.0
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
