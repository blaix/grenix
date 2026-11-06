{
  description = "Flake templates for Gren command line applications that run or install with nix or npm";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      # Collect each template's checks, so `nix flake check` here runs them all
      checksFor =
        name: system:
        nixpkgs.lib.mapAttrs' (check: drv: nixpkgs.lib.nameValuePair "${name}-${check}" drv)
          ((import ./templates/${name}/flake.nix).outputs { inherit nixpkgs; }).checks.${system};
    in
    {
      templates = {
        minimal = {
          path = ./templates/minimal;
          description = "Minimal Gren command line app";
          welcomeText = ''
            # Your Gren command line app project is ready

            1. Edit `package.json`: `name`, `bin`, `description`
            2. Edit `description` in `flake.nix`
            3. Run `nix run .`

            See `README.md` for more.
          '';
        };
        full = {
          path = ./templates/full;
          description = "Full Gren command line app with commands, help and error text, and tests";
          welcomeText = ''
            # Your Gren command line app project is ready

            1. Edit `package.json`: `name`, `bin`, `description`
            2. Edit `description` in `flake.nix`
            3. Run `nix run . -- hello`

            See `README.md` for more.
          '';
        };
        default = self.templates.minimal;
      };

      checks = forAllSystems (system: checksFor "minimal" system // checksFor "full" system);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.deadnix
              pkgs.just
              pkgs.nixfmt
              pkgs.statix
            ];
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
