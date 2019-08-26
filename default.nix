{ nixpkgs ? import <nixpkgs> {} }:

let
  inherit (nixpkgs) callPackage pkgs stdenv;
  tcrdd = callPackage ./scripts {};
in
  stdenv.mkDerivation {
    name = "tcrdd-env";
    buildInputs = with pkgs; [
      tcrdd
    ];
  }

