# Mirageos.org

Website infrastructure and content for mirageos.org

## Set up your development environment

You need opam and mirage. You can install it by following [opam's documentation](https://opam.ocaml.org/doc/Install.html).

First, install the required dependencies:

``` bash
opam install . --deps-only
```

Then, configure the project for Unix and build it:

```bash
mirage configure -f mirage/config.ml -t unix --net socket
make
```

### Running the server

After building the project, you can run the server with:
```bash
mirage/dist/www --http-port=8080
```

The server runs on port `80` by default. We change the port using `--http-port=8080` which avoids the need for sudo.

To start the server in watch mode, you can use dune directly:

```bash
dune exec mirage/dist/www -w -- --http-port=8080
```

This will restart the server on filesystem changes and reload the pages automatically.

### Running on Solo5

First, you need to ensure that you have a way for the unikernel to communicate with the network. See the tutorial for more details or set up a tap device as follows:
``` bash
ip link add name service type bridge
ip addr add 10.0.0.1/24 dev service
ip tuntap add dev tap0 mode tap
ip link set tap0 master service
ip link set dev tap0 up
ip link set service up
```

Then configure and build the unikernel

``` bash
mirage configure -f mirage/config.ml -t hvt
make
```

Finally, you can run it with the tap device:
``` bash
solo5-hvt --net:service=tap0 -- mirage/dist/www.hvt --ipv4=10.0.0.2/24 --ipv4-gateway=10.0.0.1
```

### Clean up

```bash
mirage clean -f mirage/config.ml
rm -rf mirage/duniverse
```
