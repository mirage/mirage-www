#!/bin/sh
# Convenience script to run inside a Docker continer.
# 
#    docker build -t mirage-www
#    docker run -Pd mirage-www
#    docker ps

export OPAMJOBS=2
export OPAMYES=1
eval `opam config env`
opam depext -ui mirage
cd src
mirage configure --unix --net=socket --http-port=8080
rm -f main.native
make
