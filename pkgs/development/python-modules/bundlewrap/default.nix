{ lib
, buildPythonPackage
, fetchPypi
, cryptography
, jinja2
, Mako
, passlib
, pyyaml
, requests
, librouteros
, tomlkit
, rtoml
, setuptools
}:

buildPythonPackage rec {
  pname = "bundlewrap";
  version = "4.13.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-R3YXVC7vzyvLqUrloqn2JDJKfMAc9skKUiwzdeUsXrs=";
  };

  propagatedBuildInputs = [
    cryptography
    jinja2
    Mako
    passlib
    pyyaml
    requests
    librouteros
    tomlkit
    rtoml
    setuptools # needs pkg_resources at runtime
  ];

  meta = with lib; {
    description = "Config management with Python";
    homepage = "https://bundlewrap.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ hexchen ];
  };
}
