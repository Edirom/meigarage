# MEIGarage

[![Build Status](https://github.com/Edirom/MEIGarage/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/MEIGarage/actions/workflows/maven.yml)
[![GitHub](https://img.shields.io/github/license/teic/TEIGarage.svg)](https://github.com/Edirom/MEIGarage/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Edirom/MEIGarage.svg)](https://github.com/Edirom/MEIGarage/releases)
[![Docker Automated build](https://github.com/Edirom/MEIGarage/actions/workflows/docker.yml/badge.svg)](https://github.com/Edirom/MEIGarage/actions/workflows/docker.yml)


# About

MEIGarage is a webservice and RESTful service to transform, convert and validate various formats, focussing on the [MEI](https://music-encoding.org/) format.
MIEGarage is based on the proven [OxGarage](https://github.com/TEIC/oxgarage). 

# Docker

With Docker installed, a readymade image can be fetched from GitHub(https://github.com/Edirom/MEIGarage/actions/workflows/docker.yml).

```docker pull ghcr.io/edirom/meigarage:feature-docker-image```

```bash
docker run --rm \
    -p 8080:8080 \
    -v /your/path/to/Stylesheets:/usr/share/xml/tei/stylesheet \ 
    -v /your/path/to/TEI/P5:/usr/share/xml/tei/odd \
    -e WEBSERVICE_URL=http://localhost:8080/ege-webservice/  \
    --name oxgarage teic/oxgarage
```
Once it's running, you can point your browser at `http://localhost:8080/` for the user interface.

#### available parameters

* **WEBSERVICE_URL** : The full URL of the RESTful *web service*. This is relevant for the *web client* (aka the GUI) if you are running the docker container on a different port or with a different URL.

NB: For running the image you'll need to have the TEI Stylesheets as well as the TEI P5 sources.
There are several ways to obtain these (see "Get and install a local copy" at http://www.tei-c.org/Guidelines/P5/),  
one of them is to download the latest release of both 
[TEI](https://github.com/TEIC/TEI/releases) and [Stylesheets](https://github.com/TEIC/Stylesheets/releases) from GitHub. 
Then, the Stylesheets' root directory (i.e. which holds the `profiles` directory) must be mapped to `/usr/share/xml/tei/stylesheet` whereas for the 
P5 sources you'll need to find the subdirectory which holds the file `p5subset.xml` and map this to `/usr/share/xml/tei/odd`; (should be `xml/tei/odd`).

#### exposed ports

The Docker image exposes two ports, 8080 and 8081. If you're running OxGarage over plain old HTTP, use the 8080 connector. 
For HTTPS connections behind a 
[SSL terminating Load Balancer](https://creechy.wordpress.com/2011/08/22/ssl-termination-load-balancers-java/), please use the 8081 connector.

# Maven Build

The MEIGarage Java project can be built with Maven using

```mvn -B package --file pom.xml```

Readymade war files can be downloaded from the [GitHub Action](https://github.com/Edirom/MEIGarage/blob/feature/docker-image/.github/workflows/maven.yml)

## dependencies
