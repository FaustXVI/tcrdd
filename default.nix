{ pkgs ? (import <nixpkgs> {}), stdenv ? pkgs.stdenv }:

with pkgs;

stdenv.mkDerivation rec {
  name = "tcrdd";
  version = "latest";
  buildInputs = [ bash git ];

  src = ./.;
  phases = "installPhase fixupPhase";
  installPhase = ''
    mkdir tmp
    export SHUNIT_TMPDIR=./tmp
    mkdir -p $out/bin
    cp $src/tcrdd.sh $out/bin/tcrdd
  '';
}
