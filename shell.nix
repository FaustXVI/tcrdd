{ nixpkgs ? import <nixpkgs> {} }:

let
  inherit (nixpkgs) callPackage pkgs stdenv;
  tcrdd = callPackage ./default.nix {};
in
  stdenv.mkDerivation {
    name = "tcrdd-env";
    buildInputs = with pkgs; [
      tcrdd
    ];
  }

