{ lib, stdenv, fetchurl, autoPatchelfHook, glibc }:

stdenv.mkDerivation {
  pname = "flyline";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/HalFrgrd/flyline/releases/download/v1.3.0/libflyline-v1.3.0-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-IbsKeg5BdJb/aO+DecrcBdNeQq7jV/xkrZqNlfaTIPg=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc stdenv.cc.cc.lib ];

  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/lib/libflyline.so
  '';

  meta = with lib; {
    description = "Modern bash line editing: syntax highlighting, fuzzy history, AI integration";
    homepage = "https://github.com/HalFrgrd/flyline";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
