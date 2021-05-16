{ lib, stdenv, fetchFromGitHub, pkg-config, vapoursynth }:
let
  ext = stdenv.targetPlatform.extensions.sharedLibrary;
in
stdenv.mkDerivation rec {
  pname = "RGSF";
  version = "r5";

  src = fetchFromGitHub {
    owner = "IFeelBloated";
    repo = pname;
    rev = version;
    sha256 = "1zbf54cq44ffqjhmd01s7aw5b164b87przn9gfx5ywpqrgqk63pz";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ vapoursynth ];

  postPatch = ''
    # headers are provided by nixpkgs’ vapoursynth
    rm \
        VapourSynth.h \
        VSHelper.h
  '';

  buildPhase = ''
    runHook preBuild

    g++ -shared -fPIC -O2 \
        $(pkg-config --cflags vapoursynth) \
        -o librgsf${ext} \
        Clense.cpp RemoveGrain.cpp Repair.cpp RGVS.cpp VerticalCleaner.cpp

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D librgsf${ext} $out/lib/vapoursynth/librgsf${ext}
    runHook postInstall
  '';

  meta = with lib; {
    description = "RGVS Single Precision plugin for VapourSynth";
    homepage = "https://github.com/IFeelBloated/RGSF";
    license = with licenses; [ mit wtfpl ]; # different licenses in different files
    maintainers = with maintainers; [ sbruder ];
    platforms = platforms.all;
  };
}
