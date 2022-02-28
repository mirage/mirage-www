FROM ocaml/opam:debian-11-ocaml-4.13
RUN mkdir -p /home/opam/www/mirage
WORKDIR /home/opam/www
RUN curl -L https://github.com/tailwindlabs/tailwindcss/releases/download/v3.0.16/tailwindcss-linux-x64 -o tailwindcss && chmod +x tailwindcss
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam && cd ~/opam-repository && git pull origin master && git reset --hard 9a1bb2dc5eed8f0b26e743f597e5a1aa71c4bcd1 && opam update
RUN opam repo add mirage-dev git+https://github.com/mirage/mirage-dev.git#c01677fa050d502e34452167b2d4d121054f5e78
RUN opam install mirage
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
