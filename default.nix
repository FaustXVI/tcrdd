{ stdenv }:

stdenv.mkDerivation rec {
  name = "tcrdd";
  version = "latest";
  buildInputs = [ ];

  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    cp $src/tcrdd.sh $out/bin/tcrdd
  '';
}
