# tradukilon

This is a simple CLI for the lernu.net Esperanto dictionary.

## Usage

Usage: `tradukilon [-h|--help] [-d|--direction DIRECTION] [-w|--word WORD]`

* `-d DIRECTION`, `--direction=DIRECTION`: sets the translation direction. Must be of the format `LANG1|LANG2`, where `LANG1` and `LANG2` are 2-letter language codes. Default is `eo|en`.
* `-w WORD`, `--word=WORD`: sets the word to translate. If none is given, it will be read from stdin.
* `-h`, `--help`: show help text.

## Compiling

Compile with `crystal build src/main.cr -o tradukilon`.
