# Install

```nix
let
  tcrdd = callPackage (fetchFromGitHub {
    owner = "FaustXVI";
    repo = "tcrdd";
    rev= "master";
    sha256 = "...";
  }) {};
in stdenv.mkDerivation {
    name = "...";
    buildInputs = [
        tcrdd
    ];
}
```

# Usage

tcrdd [-g|-r]
