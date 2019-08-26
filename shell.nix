{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
stdenv.mkDerivation {
  name = "tcrdd-env";
  TEST_KEYWORD="there is no tests";
  buildInputs = with pkgs; [
    bash
    git
  ];
}

