{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
stdenv.mkDerivation {
  name = "tcrdd-env";
  TEST_KEYWORD="test_";
  buildInputs = with pkgs; [
    bash
    git
  ];
}

