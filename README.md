# Install

```nix
{ pkgs ? import <nixpkgs> {}}:

pkgs.callPackage (pkgs.fetchFromGitHub {
  owner = "FaustXVI";
  repo = "tcrdd";
  fetchSubmodules = true;
  rev= "...";
  sha256 = "...";
}) {}
```

# Usage

```
tcrdd.sh [options...] testCommand [arguments...]
```

Please type `tcrdd.sh -h` for an up-to-date list of options.
