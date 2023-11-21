{
  description = "A very basic flake";
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      compiler = "ghc947";
      overlays = [ haskellNix.overlay
        (final: prev: {
          dogProject =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = compiler;
              shell.tools = {
                cabal = {};
                hlint = {};
                haskell-language-server = {};
              };
              shell.buildInputs = with pkgs; [
                just
              ];
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.dogProject.flake {
      };
    in flake // {
      packages.default = flake.packages."dog:lib:dog";
    });
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    allow-import-from-derivation = "true";
  };
}
