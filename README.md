# Grenix

Flake templates for creating command line applications with
[Gren](https://gren-lang.org/) that can be used with nix flakes or npm.

```sh
mkdir my-app && cd my-app
nix flake init -t github:blaix/grenix        # minimal (the default)
nix flake init -t github:blaix/grenix#full   # complete foundation for a command-line app
```

`minimal` is just a hello world using `SimpleProgram`.

`full` will start you off with a well-structured command line application with:

- Argument parsing, help text, error reports, and styled output using the same modules the Gren compiler uses
- Isolated modules for your app's commands (e.g. `my-app hello` runs [`src/Command/Hello.gren`](templates/full/src/Command/Hello.gren))
- [E2E tests](https://github.com/blaix/grenix/blob/main/templates/full/src/Tests/E2E/Command/Hello.gren) that run the real commands and check their exit codes and output

`package.json` will be the single source of truth for the package name,
executable name, version, and description for both nix and npm.
Edit these values after installing the template:

```json
{
  "name": <package name>,
  "version": <version>,
  "description": <description>,
  "bin": {
    <executable name>: "app"
  },
  ...
```

You can install and run your program as a nix flake:

```
nix run .
```

Or upload to a public git repository and anyone can run or install your flake
from anywhere. If its on github, it can use the github shorthand. For example,
I pushed an example of the minimal template to `blaix/grenix-example`, so you
can run it with:

```
nix run github:blaix/grenix-example
```

or a specific tag, commit, or branch by appending it to the end:

```
nix run github:blaix/grenix-example/bye
```

You can also `npm publish` your program so people can install and run it with
`npm` or `npx` from anywhere, without nix.

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
