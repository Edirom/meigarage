# Adding new functionality with plugins

## TEIGarage/MEIGarage plugin types

Currently the garages work with converter and validation plugins(following the [Java Plugin Framework](http://jpf.sourceforge.net/)). To add a new conversion or validation a new java maven project needs to be created and used as a dependency in the main configuration project (currently [MEIGarage](https://github.com/Edirom/MEIGarage) or [TEIGarage](https://github.com/TEIC/TEIGarage), see [code structure]()).

Example for converter:

*  [tei-converter](https://github.com/TEIC/tei-converter) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/tei-converter.svg)](https://github.com/TEIC/tei-converter/releases)

Example for validator:

* [mei-validator](https://github.com/Edirom/mei-validator) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/mei-validator.svg)](https://github.com/Edirom/mei-validator/releases)

## Necessary elements

### plugin.xml

src/main/resources/META-INF/plugin.xml

### Data Types

to do

### Converter Class

`public class FooConverter implements Converter,ErrorHandler`