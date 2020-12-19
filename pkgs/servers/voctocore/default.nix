{
  python3Packages, fetchFromGitHub, 
  wrapGAppsHook
}:

python3Packages.buildPythonApplication rec {
  pname = "voctocore";
  version = "2.0a";
  format = "other";
  src = fetchFromGitHub {
    owner = "voc";
    repo = "voctomix";
    rev = "3156f3546890e6ae8d379df17e5cc718eee14b15";
    sha256 = "080d39d09srz45m6knml3vychf5g43hiqikjwxn1fy7lb7i6rqsc";
  };

  nativeBuildInputs = [ wrapGAppsHook ];

  propagatedBuildInputs = with python3Packages; [
    vocto
    sdnotify
    scipy
  ];

  strictDeps = false;

  postPatch = ''
    substituteInPlace voctocore/voctocore.py --replace "sys.path.insert(0, '.')" "sys.path.insert(0, '$out/lib/voctocore')"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib
    cp -r "voctocore" $out/lib/
    ln -s $out/lib/voctocore/voctocore.py $out/bin/voctocore
    runHook postInstall
  '';

  postFixup = ''
    patchPythonScript $out/lib/voctocore/voctocore.py
  '';
}
