{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    circt-src = {
      url = "https://github.com/llvm/circt.git";
      type = "git";
      submodules = true;
      flake= false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, circt-src }:
    let
      circt-overlay =
        (final: prev: {
          circt = prev.circt.overrideAttrs (old: {
            version = "git-${circt-src.rev}";
            src = circt-src;
          });
        });
    in
    { overlays.default = circt-overlay; } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
      in
      {
        packages.default = pkgs.circt;
        formatter = pkgs.nixpkgs-fmt;
      });
}
