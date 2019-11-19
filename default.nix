{ nixpkgs ? (import <nixpkgs> {}), stdenv ? nixpkgs.stdenv }:

with nixpkgs;

stdenv.mkDerivation rec {
  name = "tcrdd";
  version = "latest";
  buildInputs = [ bash git getopt ];

  src = ./.;
  patchPhase = ''
    cp -r $src patched
    chmod +w -R patched
    patchShebangs patched/*.sh
    substituteInPlace patched/tcrdd.sh --replace 'getopt' ${getopt}/bin/getopt
    '';
  buildPhase =''
    cd patched
    mkdir -p tmp 
    export SHUNIT_TMPDIR=./tmp
    ./tcrdd_test.sh
    cd -
    '';
  installPhase = ''
    mkdir -p $out/bin
    cp patched/tcrdd.sh $out/bin/tcrdd
  '';
}
