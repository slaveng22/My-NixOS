{ lib, fetchFromGitHub, python3Packages, gobject-introspection, wrapGAppsNoGuiHook }:

python3Packages.buildPythonPackage rec {
  pname = "python-validity";
  version = "unstable-2024-01-15";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "uunicorn";
    repo = "python-validity";
    rev = "a6bbc21dce7b8b3c3cd92378a0b2579a2fb45920";
    hash = "sha256-RflX7e6nd11pSg8mh3mjZiVGNUSdox/SKXHR4W+PhMs=";
  };

  nativeBuildInputs = [ wrapGAppsNoGuiHook gobject-introspection ];

  propagatedBuildInputs = with python3Packages; [
    cryptography
    pyusb
    pyyaml
    dbus-python
    pygobject3
  ];

  postInstall = ''
    install -D -m 644 debian/python3-validity.service \
      $out/lib/systemd/system/python3-validity.service
    substituteInPlace $out/lib/systemd/system/python3-validity.service \
      --replace /usr/lib/python-validity "$out/lib/python-validity"
  '';

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  postFixup = ''
    wrapPythonProgramsIn "$out/lib/python-validity" "$out $pythonPath"
  '';

  doCheck = false;

  meta = {
    description = "Validity fingerprint sensor driver";
    homepage = "https://github.com/uunicorn/python-validity";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
