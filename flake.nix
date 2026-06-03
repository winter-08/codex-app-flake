{
  description = "Linux-only Nix flake for am-will/codex-app";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      linuxSystems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs linuxSystems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: lib.getName pkg == "codex-app";
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        rec {
          codex-app = pkgs.callPackage ./pkgs/codex-app/package.nix { };
          default = codex-app;

          update-codex-app = pkgs.writeShellApplication {
            name = "update-codex-app";
            runtimeInputs = [
              pkgs.curl
              pkgs.jq
              pkgs.nix
              pkgs.perl
            ];
            text = builtins.readFile ./scripts/update-codex-app;
          };
        }
      );

      apps = forAllSystems (system: {
        default = self.apps.${system}.codex-app;
        codex-app = {
          type = "app";
          program = lib.getExe self.packages.${system}.codex-app;
          meta.description = "Run codex-app";
        };
        update-codex-app = {
          type = "app";
          program = lib.getExe self.packages.${system}.update-codex-app;
          meta.description = "Update codex-app release metadata";
        };
      });

      devShells = forAllSystems (system: {
        default =
          let
            pkgs = pkgsFor system;
          in
          pkgs.mkShell {
            packages = [
              self.packages.${system}.update-codex-app
              pkgs.nixfmt
            ];
          };
      });

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
