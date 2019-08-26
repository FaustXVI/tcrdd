{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
stdenv.mkDerivation {
  name = "tcrdd-env";
  buildInputs = with pkgs; [
    bash
    git
  ];
}

