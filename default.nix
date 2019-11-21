{ nixpkgs ? (import <nixpkgs> {}), stdenv ? nixpkgs.stdenv }:

with nixpkgs;

stdenv.mkDerivation {
  name = "tcrdd";
  version = "latest";
  buildInputs = [ bash git getopt ];

  src = ./.;
  patchPhase = ''
    patchShebangs *.sh
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
