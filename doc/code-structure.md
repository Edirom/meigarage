# MEIGarage and TEIGarage code structure

## About

This code based on [OxGarage](https://github.com/TEIC/oxgarage) and modularized to allow for easier maintenance and creating Garages for different usage scenarios.

[TEIGarage](https://github.com/TEIC/TEIGarage) bundles functionality for the [TEI format](https://tei-c.org/), while [MEIGarage](https://github.com/Edirom/MEIGarage) focusses on the [MEI format](https://music-encoding.org/).

The code is structured in a base and various plugins (currently following the [Java Plugin Framework](http://jpf.sourceforge.net/)). All parts are available as GitHub Maven Packages to be used as dependencies.

## Main projects

* [TEIGarage](https://github.com/TEIC/TEIGarage)
* [MEIGarage](https://github.com/Edirom/MEIGarage)

## Basis

* [ege-api](https://github.com/TEIC/ege-api)
* [ege-framework](https://github.com/TEIC/ege-framework)

## Available Plugins

Contained in TEIGarage:

* [ege-validator](https://github.com/TEIC/ege-validator)
* [ege-xsl-converter](https://github.com/TEIC/ege-xsl-converter)
* [tei-converter](https://github.com/TEIC/tei-converter)
* [oo-converter](https://github.com/TEIC/oo-converter)
* [tei-javalib](https://github.com/TEIC/tei-javalib)

Contained in MEIGarage:

* [lilypond-converter](https://github.com/Edirom/lilypond-converter)
* [mei-customization](https://github.com/Edirom/mei-customization)
* [mei-validator](https://github.com/Edirom/mei-validator)
* [mei-xsl-converter](https://github.com/Edirom/mei-xsl-converter)
* [verovio-converter](https://github.com/Edirom/verovio-converter)

## Graphical User Interfaces (GUIs)

* [ege-webclient](https://github.com/TEIC/ege-webclient): basic web GUI currently used by the TEIGarage. 
* [ViFE web client for MEIGarage](https://github.com/Edirom/vife-meigarage-webclient): customized web GUI for MEIGarage.

