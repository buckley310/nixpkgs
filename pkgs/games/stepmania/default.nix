{ lib
, stdenv
, fetchFromGitHub
, cmake
, nasm
, alsa-lib
, ffmpeg_4
, glew
, glib
, gtk2
, libmad
, libogg
, libpulseaudio
, libvorbis
, udev
}:

stdenv.mkDerivation rec {
  pname = "stepmania";
  version = "5.1.0-b2";

  src = fetchFromGitHub {
    owner = "stepmania";
    repo  = "stepmania";
    rev   = "v${version}";
    hash = "sha256-tuXByyxJ/Mkik7kr5kDzppma7tExyHrt2yCU2g9N/ig=";
  };

  patches = [
    ./0001-fix-build-with-ffmpeg-4.patch
  ];

  postPatch = ''
    sed '1i#include <ctime>' -i src/arch/ArchHooks/ArchHooks.h # gcc12
  '';

  nativeBuildInputs = [ cmake nasm ];

  buildInputs = [
    alsa-lib
    ffmpeg_4
    glew
    glib
    gtk2
    libmad
    libogg
    libpulseaudio
    libvorbis
    udev
  ];

  cmakeFlags = [
    "-DWITH_SYSTEM_FFMPEG=1"
    "-DGTK2_GDKCONFIG_INCLUDE_DIR=${gtk2.out}/lib/gtk-2.0/include"
    "-DGTK2_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
  ];

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/stepmania-5.1/stepmania $out/bin/stepmania
  '';

  meta = with lib; {
    homepage = "https://www.stepmania.com/";
    description = "Free dance and rhythm game for Windows, Mac, and Linux";
    platforms = platforms.linux;
    license = licenses.mit; # expat version
    maintainers = [ ];
    # never built on aarch64-linux since first introduction in nixpkgs
    broken = stdenv.isLinux && stdenv.isAarch64;
    mainProgram = "stepmania";
  };
}
