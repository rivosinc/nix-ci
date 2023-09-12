# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# SPDX-License-Identifier: Apache-2.0
{
  description = "Rivos Nix CI helpers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {pkgs, ...}: {
        packages.default = pkgs.dockerTools.buildImageWithNixDb {
          name = "ghcr.io/rivosinc/nix-ci";
          tag = "latest";
          copyToRoot = pkgs.buildEnv {
            name = "rivos-nix-ci-root";
            paths = with pkgs; [
              bashInteractive
              coreutils
              dockerTools.caCertificates
              fakeNss
              nix
              skopeo
            ];

            pathsToLink = ["/bin" "/etc"];
          };
          config = {
            Env = [
              "NIX_PAGER=cat"
              "USER=nobody"
            ];
          };
        };
        pre-commit.settings.hooks.alejandra.enable = true;
      };
    };
}
