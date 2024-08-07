{ lib
, fetchFromGitHub
, fetchpatch2
, stdenv
, cmake
, pkg-config
, protobuf
, python3
, ffmpeg_6
, libopus
, wrapQtAppsHook
, qtbase
, qtmultimedia
, qtsvg
, qtwayland
, qtdeclarative
, qtwebengine
, SDL2
, libevdev
, udev
, curlFull
, hidapi
, json_c
, fftw
, miniupnpc
, speexdsp
, libplacebo
, vulkan-loader
, vulkan-headers
, libunwind
, shaderc
, lcms2
, libdovi
, xxHash
}:

stdenv.mkDerivation rec {
  pname = "chiaki4deck";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "streetpea";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-NiShxa49ZKmK/3q8+PHwy7edwjaqtkOqfhd2ncWK5UQ=";
    fetchSubmodules = true;
  };

  patches = [
    # Fix build with miniupnpc 2.2.8
    # https://github.com/streetpea/chiaki4deck/pull/355
    (fetchpatch2 {
      url = "https://github.com/streetpea/chiaki4deck/commit/e5806ae39cc6e8632d0f8cccefb5b7ddd458951a.patch?full_index=1";
      hash = "sha256-0oGhymCZkhckJkvP64WNc4aaEzXlXYI84S7Blq7WgVw=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
    protobuf
    python3
    python3.pkgs.wrapPython
    python3.pkgs.protobuf
    python3.pkgs.setuptools
  ];

  buildInputs = [
    ffmpeg_6
    libopus
    qtbase
    qtmultimedia
    qtsvg
    qtdeclarative
    qtwayland
    qtwebengine
    protobuf
    SDL2
    curlFull
    hidapi
    json_c
    fftw
    miniupnpc
    libevdev
    udev
    speexdsp
    libplacebo
    vulkan-headers
    libunwind
    shaderc
    lcms2
    libdovi
    xxHash
  ];

  # handle cmake not being able to identify if curl is built with websocket support, and library name discrepancy when curl not built with cmake
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail ' WS WSS' ""

    substituteInPlace lib/CMakeLists.txt \
      --replace-fail 'libcurl_shared' 'libcurl'
  '';

  cmakeFlags = [
    "-Wno-dev"
    (lib.cmakeFeature "CHIAKI_USE_SYSTEM_CURL" "true")
  ];

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib"
  ];

  pythonPath = [
    python3.pkgs.requests
  ];

  postInstall = ''
    install -Dm755 $src/scripts/psn-account-id.py $out/bin/psn-account-id
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    homepage = "https://streetpea.github.io/chiaki4deck/";
    description = "Fork of Chiaki (Open Source Playstation Remote Play) with Enhancements for Steam Deck";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ devusb ];
    platforms = platforms.linux;
    mainProgram = "chiaki";
  };
}
