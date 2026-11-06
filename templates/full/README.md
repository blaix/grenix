# my-gren-cli

An example Gren command line application that can be run or installed with nix flakes or npm.

The Gren application lives under `src/`.
It is set up with all the scaffolding to parse and run commands with an interface similar to the gren cli.
It comes with an example `hello` command, complete with tests, to get you started.

It's runnable and installable via npm or nix.
`package.json` is the source of truth for the app name, executable name, version, and description for both.

For example, with a `package.json` like this:

```json
{
  "name": "my-gren-app",
  "version": "0.1.0",
  "description": "A Gren command line application",
  "bin": {
    "my-app": "app"
  },
  ...
```

* The npm package name is `my-gren-app`
* The installed executable name is `my-app`
* The version is `0.1.0`
* The description is `"A Gren command line application"`

Update the values in `package.json` accordingly.

You'll also want to update the flake's `description` at the top of `flake.nix`.

## Develop

```sh
nix develop     # open a shell with all dev dependencies (defined in flake.nix)
npm run build   # compile ./app
./app hello     # run the app
gren run Tests  # run the unit and E2E tests (see src/Tests)
nix flake check # run the tests and verify it builds and runs via nix and npm
```

You can also run individual shell commands with all dependencies available, without opening a dev shell, with:

```sh
nix develop -c <command>
```

## Add a command

Commands are the first word passed to your program.
For example, in `my-app hello`, `hello` is the command.
A command can have its own arguments and flags.
This project is set up so that each command maps to a module under `src/Command`.
It comes with an example `hello` command.

To add a command:

1. Define your command variant in `src/Command.gren`.
2. Define your command name and arguments by adding a `withCommand` entry to `app` in `src/App.gren`.
3. Define your command's `run` function in `src/Command/<Name>.gren`. See the included `src/Command/Hello.gren` for an example.
4. Route the command argument to your `run` function by adding a branch to `parseAndRun` in `src/Main.gren`.
5. Test actual runs of your command in `src/Tests/E2E/Command/<Name>.gren` and list it in `src/Tests/E2E.gren`.
   See `src/Tests/E2E/Command/Hello.gren` for an example.
   You can also add unit tests under `src/Tests/Unit`.

Note: Nix only sees files that git tracks, so `git add` new files before running `nix build` or `nix flake check`.

## Dependencies and compiler updates

Add dependencies with `gren package install author/name`, then commit `gren_packages/` along with `gren.json`.
Nix runs checks and builds in a sandbox, so if you forget to commit `gren_packages/`,
you'll get an error about a package it can't find.

You can update your flake dependencies with `nix flake update`.
If this updates the `gren` version, you'll need to update your `gren.json` to match
(or you'll get an `INCOMPATIBLE COMPILER` error).

## Releasing

### Bump the version

`package.json` is the source of truth for the version of both the npm package and the nix flake.

From a clean git tree, run:

```sh
npm version patch   # or minor, or major
```

That will update `package.json`, commit, and tag the repo
(you can also do these by hand).

### NPM

Run `npm login` first if you haven't before, then publish:

```sh
npm publish
```

(this will also run the build)

Then it can be installed or run like any other npm package:

```sh
npx <package-name> hello       # run without installing
npm install -g <package-name>  # or install it
<executable-name> hello        # and run the installed executable
```

### Nix Flake

You can also make the flake publicly available by pushing to a public repo:

```sh
git push --follow-tags
```

It will then be usable like any other flake via a `git+ssh://` or `git+https://` url.
Pushing to github will allow people to use the github shorthand:

```sh
nix run github:<you>/<repo> -- hello  # run without installing
nix profile add github:<you>/<repo>   # or install it
<executable-name> hello               # and run the installed executable
```

Those will install/run the latest commit on the default branch.
To use a specific tag, branch, or commit, add it to the end:

```sh
nix run github:<you>/<repo>/v0.2.0 -- hello
nix profile add github:<you>/<repo>/v0.2.0
```

You can also run it with nix locally via `nix run /path/to/repo`.
