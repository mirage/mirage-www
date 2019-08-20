FROM ocaml/opam2:alpine-3.10-ocaml-4.05
RUN opam depext -ui mirage
RUN mkdir -p /home/opam/www/src
WORKDIR /home/opam/www/src
COPY --chown=opam:root src/config.ml /home/opam/www/src/
RUN opam config exec -- mirage configure -t unix
RUN make depend
COPY --chown=opam:root . /home/opam/www
RUN opam config exec -- mirage configure -t unix
RUN opam config exec -- make
USER root
ENTRYPOINT ["/home/opam/www/src/main.native"]
