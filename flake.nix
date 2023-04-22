{
  description = "bug";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay."${system}" ];
          config.allowUnfree = true;
        };
      in
      {
        name = "bug";
        inherit self nixpkgs;
        overlay = final: prev: { };
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.bazel_5 pkgs.ghcid ];
        };
      });
}
