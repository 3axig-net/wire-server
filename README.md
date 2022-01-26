# Wire-docs

Source files for wire-server documentation hosted on https://docs.wire.com

## Reading the documentation

Visit https://docs.wire.com/

## Making contributions

The structure of this document has been heavily inspired by [this blog
post](https://www.divio.com/blog/documentation/).

We use [sphinx](https://sphinx-doc.org/) for rendering.  Here is a [cheat
sheet](https://docutils.sourceforge.net/docs/user/rst/quickref.html)
for writing re-structured text (`*.rst`).
[here is another one](https://docutils.sourceforge.net/docs/user/rst/cheatsheet.html).
And [another one](https://sublime-and-sphinx-guide.readthedocs.io/en/latest/references.html).

### Conventions

The re-structured spec text allows for choosing any underline/overline symbol
for any level. In this repository we have not been very consistent. For any new
contribution let's stick to this convention:

```rst
######
Part 1
######

*********
Chapter 1
*********

Section 1
=========

Sub-section 1
-------------

Sub-sub-section 1
^^^^^^^^^^^^^^^^^

Paragraph 1
~~~~~~~~~~~

Sub-paragraph 1
+++++++++++++++
```

If another level is needed, please add the chosen symbol here.

## Building the docs

*Note: when switching from a docker-based building to a local building, you might encounter permission issues due to the build directory being owned by root. These can be solved by cleaning the build directory: `sudo rm -rf ./build/`*

### Dependencies

Install the dependencies locally:

1. Install [Nix](https://nixos.org/download.html)
   * MacOS users with a recent Mac might need to follow [these
   instructions](https://nixos.org/nix/manual/#sect-macos-installation)
   * Debian users can use their distro's `nix` package, and should remember
   to add their user to the `nix-users` group in /etc/group, and re-start
   their login session.
2. Install [Direnv](https://direnv.net/).
   * On debian, you can install the `direnv` package. On MacOS use `brew install direnv`.
   * On NixOS with home-manager, you can set `programs.direnv.enable = true;`.
   * Make sure direnv is hooked into your shell via it's appripriate `rc` file.
     Add `eval "$(direnv hook bash|zsh|fish)"` to your ~/.(bash|zsh|fish)rc .
   * When successfully installed and hooked, direnv should ask you to `direnv allow`
     the current `.envrc` when you cd to this repository.
     See the [Installation documentation](https://direnv.net/docs/installation.html) for further details.

Now, whenever you cd to wire-docs, you will have the relevant binaries (make, sphinx, rst2pdf, ...) in your PATH.

### Generating html output

```
make html
```

### Generating a PDF file

NOTE: support is experimental and resulting pdf may not have great formatting. See the [rst2pdf](https://rst2pdf.org/static/manual.pdf) manual to improve the configuration here so the resulting PDF becomes nicer.

Run `make pdf` and look at files in `./build/pdf/`.

You can use the `make dev-pdf` target to get auto-refreshing PDF files as you save source files. (requires a PDF viewer installed globally)

### Local development environment for file watching

Enter a *development mode* by running `make dev-run` to start a local server and file watcher.

Look at results by opening build/html/index.html which will auto-update whenever files under ./src change.

## Building the docs with docker

You need `docker` available on your system.
The docker image that is used is defined in the `Makefile`. To build the docker image locally (e.g. after updating dependencies) run `make docker`.

### html

Generate docs using docker (so you don't need to install python dependencies yourself)

```
make docs
```

See build/html/index.html

### pdf

```
make docs-pdf
```

Then see build/pdf/

## For maintainers (Wire employees)

### Upload to S3

CI is set up to do this automatically on a push to master. If for some reason you wish to upload manually to S3:

(You need amazon credentials for pushing to S3)

```
make push
```

Please note that cloudfront CDN has a certain cache duration (at the time of writing: 1 minute), so changes will take a bit of time to take effect.
