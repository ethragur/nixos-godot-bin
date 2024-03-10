{ stdenv
, lib
, autoPatchelfHook
, makeWrapper
, fetchurl
, unzip
, udev
, fontconfig
, dbus
, alsaLib
, libXcursor
, libXinerama
, libXrandr
, libXrender
, libX11
, libXi
, libXext
, libxcb
, libxkbcommon
, libXfixes
, libpulseaudio
, libGL
, vulkan-loader
, godotDesktopFile
, godotIconPNG
, godotIconSVG
, godotManpage
}:

let
  qualifier = "stable";
in

stdenv.mkDerivation rec {
  pname = "godot-bin";
  version = "4.2.1";

  src = fetchurl {
    url = "https://downloads.tuxfamily.org/godotengine/${version}/Godot_v${version}-${qualifier}_linux.x86_64.zip";
    sha256 = "hjEannW3RF60IVMS5gTfH2nHLUZBrz5nBJ4wNWrjdmA=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper unzip ];

  buildInputs = [
    fontconfig
    dbus
    dbus.lib
    udev
    alsaLib
    vulkan-loader
    libXcursor
    libXinerama
    libXrandr
    libXrender
    libX11
    libXi
    libXfixes
    libXext
    libxcb
    libxkbcommon
    libpulseaudio
    libGL
  ];

  libraries = lib.makeLibraryPath buildInputs;

  unpackCmd = "unzip $curSrc -d source";
  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 Godot_v${version}-${qualifier}_linux.x86_64 $out/bin/godot

    # Only create a desktop file, if the necessary variables are set
    # these are set only, if one installs this program using flakes.
    if [[ -f "${godotDesktopFile}" ]]; then
      mkdir -p "$out/man/share/man/man6"
      cp ${godotManpage} "$out/man/share/man/man6/"

      mkdir -p $out/share/{applications,icons/hicolor/scalable/apps}
      cp ${godotDesktopFile} "$out/share/applications/org.godotengine.Godot.desktop"
      cp ${godotIconSVG} "$out/share/icons/hicolor/scalable/apps/godot.svg"
      cp ${godotIconPNG} "$out/share/icons/godot.png"
      substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
        --replace "Exec=godot" "Exec=$out/bin/godot"
    fi
  '';

  postFixup = ''
    wrapProgram $out/bin/godot \
      --set LD_LIBRARY_PATH ${libraries}
  '';

  meta = {
    homepage = "https://godotengine.org";
    description = "Free and Open Source 2D and 3D game engine";
    license = lib.licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" ];
    maintainers = [ lib.maintainers.twey ];
  };
}
