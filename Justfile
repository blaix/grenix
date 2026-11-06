nix_files := `git ls-files --cached --others --exclude-standard '*.nix' | sort | tr '\n' ' '`

# ----------------------------------------------
# TOOLING
# ----------------------------------------------

# Bump the nixpkgs pin everywhere.
update:
    nix flake update
    for template in templates/*/; do nix flake update --flake "./$template"; done

# Format and remove dead nix code.
format:
    nixfmt {{ nix_files }}
    deadnix --edit {{ nix_files }}

# ----------------------------------------------
# VERIFICATIONS
# ----------------------------------------------

# Run every verification recipe we have
verify: lint check e2e
    @echo "Done"

# Check nix formatting and common errors
lint:
    nixfmt --check {{ nix_files }}
    deadnix --fail {{ nix_files }}
    statix check .

# Run every template's flake checks in the Nix sandbox.
check:
    nix flake check -L

# Generate a project from each template and exercise it end to end.
e2e:
    bash scripts/e2e.sh

