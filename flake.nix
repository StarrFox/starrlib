{
  description = "common starr utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        app = pkgs.poetry2nix.mkPoetryApplication {
          projectDir = ./.;
        };

        packageName = "starrlib";
      in {
        packages.${packageName} = app;

        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ poetry commitizen just direnv ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}