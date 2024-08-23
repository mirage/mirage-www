FROM ocaml/opam:debian-12-ocaml-5.2
RUN sudo apt-get update && sudo apt-get install autoconf automake -y --no-install-recommends
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN cd ~/opam-repository && git pull origin master && git reset --hard 705cfbfe709bba2533a3cd6164b7dab37fca0342
RUN opam update
RUN opam install 'mirage>=4.5.0'
COPY --chown=opam:root mirage/config.ml /home/opam/www/mirage/
COPY --chown=opam:root mirageio.opam /home/opam/www/
ARG TARGET=unix
ARG EXTRA_FLAGS=
ARG EXTRA_FLAGS_NO_METRICS="--tls=true --separate-networks"
RUN opam pin add -n ocaml-solo5 'https://github.com/shym/ocaml-solo5.git#ocaml-5.2-reb'
RUN opam exec -- mirage configure -f mirage/config.ml -t $TARGET $EXTRA_FLAGS_NO_METRICS
RUN opam exec -- make depend
COPY --chown=opam:root . /home/opam/www
RUN opam exec -- mirage configure -f mirage/config.ml -t $TARGET $EXTRA_FLAGS_NO_METRICS
RUN opam exec -- dune build mirage/ --profile release
RUN if [ $TARGET = hvt ]; then sudo cp mirage/dist/www.$TARGET /unikernel.$TARGET; fi
