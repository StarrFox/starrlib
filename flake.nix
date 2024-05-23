{
  description = "common starr utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nix-systems,
    pre-commit-hooks,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = import nix-systems;
      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: let
        python = pkgs.python311;
        pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);

        packageName = "starrlib";
      in {
        packages.${packageName} = python.pkgs.buildPythonPackage {
          src = ./.;
          pname = packageName;
          inherit (pyproject.tool.poetry) version;
          format = "pyproject";
          pythonImportsCheck = [packageName];
          nativeBuildInputs = [
            python.pkgs.poetry-core
          ];
          propagatedBuildInputs = with python.pkgs; [];

          meta.mainProgram = packageName;
        };

        packages.default = self'.packages.${packageName};

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              black.enable = true;
              alejandra.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          name = packageName;
          inherit (self'.checks.pre-commit-check) shellHook;
          packages = with pkgs; [
            (poetry.withPlugins (ps: with ps; [poetry-plugin-up]))
            python
            just
            alejandra
            python.pkgs.black
            python.pkgs.isort
            python.pkgs.vulture
          ];
        };
      };
    };
}
