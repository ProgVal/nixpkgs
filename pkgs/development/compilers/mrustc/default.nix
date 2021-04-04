{ lib, stdenv
, fetchFromGitHub
, zlib
}:

let
  version = "0.10-dev";
  tag = "v${version}";
  rev = "75a0f59308bd6f903387774fbcb9ea9a65f89d0d";
in

stdenv.mkDerivation rec {
  pname = "mrustc";
  inherit version;

  # Always update minicargo.nix and bootstrap.nix in lockstep with this
  src = fetchFromGitHub {
    owner = "thepowersgang";
    repo = "mrustc";
    rev = rev;
    sha256 = "0csj509bypgbwfxzyy5ivh938xbdhp81waymvkgm4p9zg9yvifx3";
  };

  postPatch = ''
    sed -i 's/\$(shell git show --pretty=%H -s)/${rev}/' Makefile
    sed -i 's/\$(shell git symbolic-ref -q --short HEAD || git describe --tags --exact-match)/${tag}/' Makefile
    sed -i 's/\$(shell git diff-index --quiet HEAD; echo $$?)/0/' Makefile
  '';

  strictDeps = true;
  buildInputs = [ zlib ];
  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/mrustc $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mutabah's Rust Compiler";
    longDescription = ''
      In-progress alternative rust compiler, written in C++.
      Capable of building a fully-working copy of rustc,
      but not yet suitable for everyday use.
    '';
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ progval r-burns ];
    platforms = [ "x86_64-linux" ];
  };
}
