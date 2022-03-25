FROM ocaml/opam:debian-11-ocaml-4.13
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam && cd ~/opam-repository && git pull origin master && git reset --hard 7bf7a6043f0a3449dcd779bb5b9cbe8e4409a4fe && opam update
RUN opam pin git+https://github.com/tmattio/opam-tailwindcss#fb0f82edd09999f7be033ab1785ba5f6b60ed8f6
RUN opam pin https://github.com/mirage/mirage.git#ed645fa09a940f06fff606f4ac8390388dbe34fa
COPY --chown=opam:root mirage/config.ml /home/opam/www/mirage/
COPY --chown=opam:root mirageio.opam /home/opam/www/
ARG TARGET=unix
ARG EXTRA_FLAGS=
RUN opam config exec -- mirage configure -f mirage/config.ml -t $TARGET $EXTRA_FLAGS
RUN opam config exec -- make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -f mirage/config.ml -t $TARGET $EXTRA_FLAGS
RUN opam config exec -- dune build mirage/ --profile release
RUN if [ $TARGET = hvt ]; then sudo cp mirage/dist/www.$TARGET /unikernel.$TARGET; fi
