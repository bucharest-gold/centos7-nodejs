# Docker Images for Node.js Applications

[![Build Status](https://travis-ci.org/bucharest-gold/centos7-nodejs.svg?branch=master)](https://travis-ci.org/bucharest-gold/centos7-nodejs)
[![](https://images.microbadger.com/badges/image/bucharestgold/centos7-nodejs.svg)](https://microbadger.com/images/bucharestgold/centos7-nodejs "Get your own image badge on microbadger.com")

[![docker hub stats](http://dockeri.co/image/bucharestgold/centos7-nodejs)](https://hub.docker.com/r/bucharestgold/centos7-nodejs/)

## Versions

Node.js versions [currently provided](https://hub.docker.com/r/bucharestgold/centos7-nodejs/tags/):

<!-- versions.start -->
* **`7.10.0`**: (7.10.0, 7, 7.10, current, latest)
* **`6.10.3`**: (6.10.3, 6, 6.10, lts, Boron)
* **`5.12.0`**: (5.12.0, 5, 5.12)
* **`4.8.3`**: (4.8.3, 4, 4.8, lts, Argon)
<!-- versions.end -->

## Usage

To use this image with Docker, place a `Dockerfile` in the root of your source
repository that contains a single line:

```Dockerfile
FROM bucharestgold/centos7-nodejs:latest
```

You can then build and run your application with standard Docker commands.

```sh
$ cd my-app
$ docker build -t my-app .
$ docker run -p 8080:8080 my-app
```

This image can also be used with OpenShift. To do that, you'll still need the
`Dockerfile` in the root of your source repository, then run:

```sh
$ cd myProject
$ oc new-build --binary --name=my-app -l app=myProject
$ npm install
$ oc start-build my-app --from-dir=. --follow
$ oc new-app my-app -l app=my-app
$ oc expose svc/my-app
```

### Environment variables

Use the following environment variables to configure the runtime behavior of the
application image created from this builder image.

NAME        | Description
------------|-------------
NPM_RUN     | Select an alternate / custom runtime mode, defined in your `package.json` file's [`scripts`](https://docs.npmjs.com/misc/scripts) section (default: npm run "start")
NPM_MIRROR  | Sets the npm registry URL
NODE_ENV    | Node.js runtime mode (default: "production")
HTTP_PROXY  | use an npm proxy during assembly
HTTPS_PROXY | use an npm proxy during assembly

## Building this repository

To build these images yourself is pretty easy.

### Requirements - docker-squash

`pip install docker-squash`

Then just clone a copy of this repo to fetch the build sources:

```
$ git clone https://github.com/bucharest-gold/centos7-nodejs.git
$ cd centos7-nodejs
$ make all

```
