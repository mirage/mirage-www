## MirageOS Website

This repository contains the MirageOS public website, <https://mirage.io/>.

It provides information about the project as well as the blog and wiki.

It also serves as a good first self-hosting test case.

### Building with Docker

The easiest way to get started is to build using Docker:

```
docker build -t mirage-www .
docker run --rm -it --init -p 80:8080 mirage-www ./www --http-port 8080
```

Then browse to <http://127.0.0.1/>.

You can build for other targets with e.g. `docker build --build-arg TARGET=hvt ...`

### Building without Docker

To build this website, first use `make prepare`
You can then build the mirage application in the src/ directory:
```
cd src && mirage configure && make
```

### Configuration

For unikernel configuration options, use `mirage configure --help` in `src`.

To update, send a pull request. When successfully merged, the OCurrent deployer
at <https://deploy.ocamllabs.io/> will build the new unikernel and deploy it
to our packet.net hosting, where it should appear at <https://mirage.io/>.
See [pipeline.ml](https://github.com/ocurrent/ocurrent-deployer/blob/master/src/pipeline.ml)
for the deployment pipeline.
