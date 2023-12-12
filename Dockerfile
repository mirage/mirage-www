FROM ocaml/opam:debian-12-ocaml-4.14
RUN sudo apt-get update && sudo apt-get install autoconf automake -y --no-install-recommends
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam && cd ~/opam-repository && git pull origin master && git reset --hard 30b1b97d735732e40996cf2e6b06d478ac40633f && opam update
RUN opam pin tailwindcss.dev https://github.com/tmattio/opam-tailwindcss/archive/3e60fc32bbcf82525999d83ad0f395e16107026b.tar.gz
RUN opam repo add mirage-dev git+https://github.com/mirage/mirage-dev.git#749c02302f8f15e609332edbe827541558554a80
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
