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
tcrdd [options...] testCommand [arguments...]

Options:
    -g                  assume the tests will pass (green)
    -r                  assume the tests will fail (red)
    -m MESSAGE          use the provided commit message
```
