# Grenix

Flake templates for creating a Gren command line application that can be run or installed with nix flakes or npm.

```sh
mkdir my-app && cd my-app
nix flake init -t github:blaix/grenix        # minimal (the default)
nix flake init -t github:blaix/grenix#full   # complete foundation for a command-line app
```

`minimal` is just a hello world.

`full` will start you off with a well-structured command line application with:

- Commands, argument parsing, help text, and error reports using the same modules the Gren compiler uses
- Isolated command modules (see [`src/Command/Hello.gren`](src/Command/Hello.gren) for an example)
- Unit tests, and E2E tests that run the real commands and check their exit codes and output
- `package.json` as a single source of truth for the package name, executable name, version, and description for both nix and npm

You can see what you get from each template by viewing the files under [`templates/`](templates/).

See each template's `README.md` for more details.

## Working on grenix itself

Enter the dev shell with `nix develop`.

Tests and checks:

* `just check`: Runs every template's checks in the Nix sandbox
* `just e2e`: Generates a project from each template and exercises it
* `just lint`: Lints the nix files

`just verify` will run them all.

See [`Justfile`](Justfile) for all available recipes.

Note: nix only sees files git tracks, so `git add` new template files before running nix builds/checks/ect or e2e tests.
