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

```
tcrdd.sh [options...] testCommand [arguments...]
```

Please type `tcrdd.sh -h` for an up-to-date list of options.
