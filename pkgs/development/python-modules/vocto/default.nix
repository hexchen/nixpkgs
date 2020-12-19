{ 
  buildPythonPackage, fetchFromGitHub, python,
  gobject-introspection,
  gst-python,
  pygobject3,
  gst_all_1,
}:

buildPythonPackage rec {
  pname = "vocto";
  version = "2.0a";
  format = "other";
  src = fetchFromGitHub {
    owner = "voc";
    repo = "voctomix";
    rev = "3156f3546890e6ae8d379df17e5cc718eee14b15";
    sha256 = "080d39d09srz45m6knml3vychf5g43hiqikjwxn1fy7lb7i6rqsc";
  };

  propagatedBuildInputs = with gst_all_1; [
    gobject-introspection
    gst-python
    pygobject3
    gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-plugins-base 
    gst-vaapi gst-libav 
  ];

  strictDeps = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${python.libPrefix}/site-packages
    cp -r "vocto" $out/lib/${python.libPrefix}/site-packages
    runHook postInstall 
  '';
}
