{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Utils for Flakes
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Project-specific
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.devshell.flakeModule or ({ ... }: { })
        inputs.treefmt-nix.flakeModule or ({ ... }: { })
      ];

      perSystem =
        {
          system,
          inputs',
          pkgs,
          ...
        }:
        let
          overlays = [
            inputs.rust-overlay.overlays.default
            inputs.devshell.overlays.default
          ];
          pkgs = import inputs.nixpkgs-unstable {
            inherit system overlays;
          };
          rust-target = pkgs.pkgsStatic.stdenv.targetPlatform.rust.rustcTarget;
          rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
            targets = [
              rust-target
            ];
          };

        in
        {
          _module.args.pkgs = pkgs;

          devshells = rec {
            default = dev;
            dev = { extraModulesPath, ... }: {
              name = "dev";
              imports = [
                "${extraModulesPath}/git/hooks.nix"
              ];
              # LSP for Nix
              packages = with pkgs; [
                stdenv.cc
                coreutils
                nixd

                rust-toolchain
              ];
              git.hooks = {
                enable = true;
                pre-commit.text = "nix flake check";
              };
            };
          };
          treefmt = {
            programs.mdformat.enable = true; # Markdown
            programs.nixfmt.enable = true; # Nix
            programs.rustfmt.enable = true; # Rust
            programs.taplo.enable = true; # TOML
          };
        };
    };
}
