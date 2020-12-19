{
  python3Packages, fetchFromGitHub, 
  wrapGAppsHook,
  gtk3
}:

python3Packages.buildPythonApplication rec {
  pname = "voctogui";
  version = "2.0a";
  format = "other";
  src = fetchFromGitHub {
    owner = "voc";
    repo = "voctomix";
    rev = "3156f3546890e6ae8d379df17e5cc718eee14b15";
    sha256 = "080d39d09srz45m6knml3vychf5g43hiqikjwxn1fy7lb7i6rqsc";
  };

  nativeBuildInputs = [ wrapGAppsHook ];

  propagatedBuildInputs = [
    gtk3
  ] ++ (with python3Packages; [
    vocto
    scipy
  ]);

  strictDeps = false;

  postPatch = ''
    substituteInPlace voctogui/voctogui.py --replace "sys.path.insert(0, '.')" "sys.path.insert(0, '$out/lib/voctogui')"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib
    cp -r "voctogui" $out/lib/
    ln -s $out/lib/voctogui/voctogui.py $out/bin/voctogui
    runHook postInstall
  '';

  postFixup = ''
    patchPythonScript $out/lib/voctogui/voctogui.py
  '';
}
