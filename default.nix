{ nixpkgs ? (import <nixpkgs> {}), stdenv ? nixpkgs.stdenv }:

with nixpkgs;

stdenv.mkDerivation {
  name = "tcrdd";
  version = "latest";
  src = ./.;
  buildInputs = [ bash git getopt ];
  patchPhase = ''
    patchShebangs .
    substituteInPlace tcrdd.sh \
      --replace 'getopt' ${getopt}/bin/getopt \
      --replace 'git' ${git}/bin/git
    '';
  buildPhase =''
    mkdir -p tmp 
    export SHUNIT_TMPDIR=./tmp
    ./tcrdd_test.sh
    '';
  installPhase = ''
    mkdir -p $out/bin
    cp tcrdd.sh $out/bin/tcrdd
  '';
}
