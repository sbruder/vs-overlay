{ lib, vapoursynthPlugins, buildPythonPackage, fetchFromGitHub, python3, vapoursynth }:
let
  propagatedBinaryPlugins = with vapoursynthPlugins; [
    adaptivegrain
    bilateral
    eedi3m
    f3kdb
    ffms2
    nnedi3cl
    scxvid
    wwxd
  ];
in
buildPythonPackage rec {
  pname = "vardefunc";
  version = "unstable-2021-05-12";

  src = fetchFromGitHub {
    owner = "Ichunjo";
    repo = pname;
    rev = "d36c8288a5903efde8a6150947f4a96d9153a106";
    sha256 = "1kcsprlw0gxrq9sdwmp23f5rrkssvra9ni439x6ik1p6g5wgkh71";
  };

  propagatedBuildInputs = (with vapoursynthPlugins; [
    fvsfunc
    havsfunc
    vsutil
  ]) ++ propagatedBinaryPlugins;

  format = "other";

  installPhase = ''
    runHook preInstall

    install -d $out/${python3.sitePackages}/vardefunc
    install \
        vardefunc.py \
        placebo.py \
        $out/${python3.sitePackages}/vardefunc

    runHook postInstall
  '';

  checkInputs = [ (vapoursynth.withPlugins propagatedBinaryPlugins) ];
  checkPhase = ''
    runHook preCheck
    PYTHONPATH=$out/${python3.sitePackages}:$PYTHONPATH
    runHook postCheck
  '';
  pythonImportsCheck = [ "vardefunc" ];

  meta = with lib; {
    description = " Some functions that may be useful ";
    homepage = "https://github.com/Ichunjo/vardefunc";
    license = licenses.unfree; # no license
    maintainers = with maintainers; [ sbruder ];
    platforms = platforms.all;
  };
}
