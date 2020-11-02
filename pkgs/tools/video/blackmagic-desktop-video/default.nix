{ stdenv, requireFile, lib,
  libcxx, libcxxabi
}:

stdenv.mkDerivation rec {
  pname = "blackmagic-desktop-video";
  version = "11.6";

  buildInputs = [
    libcxx libcxxabi
  ];

  src = requireFile {
    name = "Blackmagic_Desktop_Video_Linux_11.6.tar.gz";
    url = "https://www.blackmagicdesign.com/support/download/d399ada95c2b49ffad3031bda413acb5/Linux";
    sha256 = "0qwm1b3gy0k7j1bimkxwwr77g8hrsybs9jp90b46kzcy06mcp380";
  };

  setSourceRoot = ''
    tar xf Blackmagic_Desktop_Video_Linux_11.6/other/x86_64/desktopvideo-11.6a26-x86_64.tar.gz
    sourceRoot=$NIX_BUILD_TOP/desktopvideo-11.6a26-x86_64
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/doc,lib}
    cp -r $sourceRoot/usr/share/doc/desktopvideo $out/share/doc
    cp $sourceRoot/usr/lib/*.so $out/lib
    ln -s ${libcxx}/lib/* ${libcxxabi}/lib/* $out/lib
    cp $sourceRoot/usr/lib/blackmagic/DesktopVideo/libgcc_s.so.1 $out/lib/
    cp $sourceRoot/usr/lib/blackmagic/DesktopVideo/DesktopVideoHelper $out/bin/
    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      --set-rpath "$out/lib:${lib.makeLibraryPath [ libcxx libcxxabi ]}" \
      $out/bin/DesktopVideoHelper
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.blackmagicdesign.com/support/family/capture-and-playback";
    maintainers = [ maintainers.hexchen ];
    license = licenses.unfree;
    description = "Supporting applications for Blackmagic Decklink. Doesn't include the desktop applications, only the helper required to make the driver work.";
    platforms = platforms.linux;
  };
}
