
{
  description = "TODO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };
  outputs = { self, nixpkgs, devshell, utils, }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };
      in
      {
        git.hooks = {
          enable = true;
          pre-commit.text = "nix flake check";
        };

        devShells.default = (pkgs.devshell.mkShell {
          name = "dev";
          packages = with pkgs; [
            stdenv.cc
            coreutils

            typst
            tinymist
          ];
        
          commands = [
            {
              name = "watch-typst";
              command = ''
                typst watch --root "$PRJ_ROOT" "$PRJ_ROOT/main.typ"
              '';
              help = "watch and recompile the main typst project";
            }
          ];
        });
      });
  # });
}
