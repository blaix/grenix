#!/usr/bin/env bash
# Verify the real `nix flake init -t ...` usage end-to-end.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
message="Hello. I like you and I love you."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

assert_equal() {
    if [ "$1" != "$2" ]; then
        printf 'FAILED\n  expected: %s\n  actual:   %s\n' "$2" "$1" >&2
        exit 1
    fi
}

test_template() {
    local template="$1"
    shift
    local args=("$@")
    local project="$work/$template"

    echo "=== $template: nix flake init"
    mkdir "$project"
    cd "$project"
    git init --quiet .
    # git+file, like a real fetch from GitHub, only copies tracked files.
    nix flake init --template "git+file://$repo#$template"

    # name can be any valid npm name, even if it's an invalid nix name.
    # use a scoped npm name (@foo/bar) to test this.
    # the bin name must be valid for both.
    echo "=== $template: rename project and bin"
    sed -i.bak \
        -e 's|"name": "my-gren-cli"|"name": "@test/hello-tool"|' \
        -e 's|"my-gren-cli": "app"|"hello-tool": "app"|' \
        package.json
    rm package.json.bak

    echo "=== $template: nix build, run and check"
    nix build
    assert_equal "$(./result/bin/hello-tool "${args[@]+"${args[@]}"}")" "$message"
    assert_equal "$(nix run . -- "${args[@]+"${args[@]}"}")" "$message"
    nix flake check

    echo "=== $template: nix profile add"
    nix profile add --profile "$work/$template-profile" "$project"
    assert_equal "$("$work/$template-profile/bin/hello-tool" "${args[@]+"${args[@]}"}")" "$message"

    echo "=== $template: npm pack and global install"
    nix develop --command npm pack
    local tarball_contents
    tarball_contents="$(tar tzf ./*.tgz | LC_ALL=C sort | tr '\n' ' ')"
    assert_equal "$tarball_contents" "package/README.md package/app package/package.json "
    nix develop --command npm install --global --prefix "$work/$template-npm" ./*.tgz
    assert_equal "$(nix develop --command "$work/$template-npm/bin/hello-tool" "${args[@]+"${args[@]}"}")" "$message"

    echo "=== $template: a new dependency needs git add before Nix can see it"
    nix develop --command gren package install gren-lang/parser < <(yes)
    if nix build --no-link 2>/dev/null; then
        echo "FAILED: expected the build to fail with an untracked vendored package" >&2
        exit 1
    fi
    git add gren_packages
    nix build --no-link
}

test_template minimal
test_template full hello

echo "=== all passed"
