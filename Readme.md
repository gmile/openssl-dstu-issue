# OpenSSL with DSTU patches build suite

This repo contains Dockerfiles to help build & test OpenSSL with DSTU patches.

Below all 3 Dockerfiles are described.

## `Dockerfile`

Describes an image suitable for development process.

### Building a conatiner image

In order to build an image, run:

```
docker build --file Dockerfile --tag gmile/openssl-dstu-dev .
```

## `Dockerfile.build`

Describes an image suitable for .deb publishing process.

### Building a conatiner image

In order to build an image, run:

```
docker build --file Dockerfile.build --tag gmile/openssl-dstu-build .
```

### Running a container

Before starting container, export the gpg keys on the host operating system:

```bash
mkdir -p /tmp/keys
gpg --export 9BFCF21AFB94ADF13290496EA44ED18DF134E42B > /tmp/keys/public.key
gpg --export-secret-key 9BFCF21AFB94ADF13290496EA44ED18DF134E42B > /tmp/keys/private.key
```

Start container:

```
docker run --mount type=bind,source=/tmp/keys,destination=/keys --rm -it gmile/openssl-dstu-build bash
```

After starting container, run:

```
gpg --import /keys/private.key /keys/public.key
DEB_BUILD_OPTIONS=nocheck debuild -b
```

After building the package, go one level up the directory tree and run:

```
dput ppa:iamexile/openssl-with-dstu openssl_1.0.1f-1ubuntu2.24_source.changes
```

### TODO

- squash some RUN commands,
- only extract selected files (e.g. only patches) from openssl_1.0.1f-1ubuntu9dstu2~utopic.debian.tar.gz
- change release name in changelog (e.g. call it openssl-with-dstu instead of just openssl)
- remove DEB_BUILD_OPTIONS=nocheck from debuild (e.g. do not skip tests)
- how to pass gpg key from host to docker without temporal keys exporting?
- try a more recent Ubuntu LTS (at least Utopic should work?)
- try a more recent OpenSSL

## `Dockerfile.erlang`

Describes an image suitable for testing erlang + libssl1.0.0 with DSTU patches.

### Building an image

In order to build an image, run:

```
docker build --file Dockerfile.erlang --tag gmile/openssl-dstu-erlang .
```
