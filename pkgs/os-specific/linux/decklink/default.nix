{ stdenv, requireFile, fetchpatch, kernel }:

stdenv.mkDerivation rec {
  pname = "decklink";
  version = "11.6";

  src = requireFile {
    name = "Blackmagic_Desktop_Video_Linux_11.6.tar.gz";
    url = "https://www.blackmagicdesign.com/support/download/d399ada95c2b49ffad3031bda413acb5/Linux";
    sha256 = "0qwm1b3gy0k7j1bimkxwwr77g8hrsybs9jp90b46kzcy06mcp380";
  };

  patches = [
    (fetchpatch {
      name = "01-fix-makefile.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/01-fix-makefile.patch?h=decklink&id=8f19ef584c0603105415160d2ba4e8dfa47495ce";
      sha256 = "1pk8zfi0clmysla25jmcqnq7sx2bnjflrarhqkqbkl8crigyspf5";
    })
    (fetchpatch {
      name = "02-fix-get_user_pages-and-mmap_lock.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/02-fix-get_user_pages-and-mmap_lock.patch?h=decklink&id=8f19ef584c0603105415160d2ba4e8dfa47495ce";
      sha256 = "08m4qwrk0vg8rix59y591bjih95d2wp6bmm1p37nyfvhi2n9jw2m";
    })
    (fetchpatch {
      name = "03-fix-have_unlocked_ioctl.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/03-fix-have_unlocked_ioctl.patch?h=decklink&id=8f19ef584c0603105415160d2ba4e8dfa47495ce";
      sha256 = "0j9p62qa4mc6ir2v4fzrdapdrvi1dabrjrx1c295pwa3vmsi1x4f";
    })
  ];

  KERNELDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  nativeBuildInputs =  kernel.moduleBuildDependencies;

  setSourceRoot = ''
    tar xf Blackmagic_Desktop_Video_Linux_11.6/other/x86_64/desktopvideo-11.6a26-x86_64.tar.gz
    sourceRoot=$NIX_BUILD_TOP/desktopvideo-11.6a26-x86_64/usr/src
  '';

  buildPhase = ''
    runHook preBuild

    make -C $sourceRoot/blackmagic-11.6a26 -j$NIX_BUILD_CORES
    make -C $sourceRoot/blackmagic-io-11.6a26 -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -C $KERNELDIR M=$sourceRoot/blackmagic-11.6a26 modules_install
    make -C $KERNELDIR M=$sourceRoot/blackmagic-io-11.6a26 modules_install

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.blackmagicdesign.com/support/family/capture-and-playback";
    maintainers = [ maintainers.hexchen ];
    license = licenses.unfree;
    description = "Kernel module for the Blackmagic Design Decklink cards";
    platforms = platforms.linux;
  };
}
