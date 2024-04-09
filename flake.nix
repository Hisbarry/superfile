{
  description = "CLI for searching packages on search.nixos.org";
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    flake-utils.url = github:numtide/flake-utils;

    flake-compat.url = github:edolstra/flake-compat;
    flake-compat.flake = false;

    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    # gomod2nix.inputs.utils.follows = "flake-utils";
  };

  outputs = inputs @ {...}:
    inputs.flake-utils.lib.eachDefaultSystem
    (
      system: let
        overlays = [
          inputs.gomod2nix.overlays.default
        ];
        pkgs = import inputs.nixpkgs {
          inherit system overlays;
        };
      in rec {
        packages = rec {
          superfile = pkgs.buildGoApplication {
            pname = "superfile";
            version = "0.1.0";
            src = ./src;
            modules = ./src/gomod2nix.toml;
          };
          default = superfile;
        };

        apps = rec {
          superfile = {
            type = "app";
            program = "${packages.superfile}/bin/superfile";
          };
          default = superfile;
        };

        devShells = rec {
          default = pkgs.mkShell {
            packages = with pkgs; [
              ## golang
              delve
              go-outline
              go
              golangci-lint
              gopkgs
              gopls
              gotools
              nix
              gomod2nix
              nixpkgs-fmt
            ];
          };
        };
      }
    );
}