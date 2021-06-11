{ lib, mkDerivation, fetchFromGitHub, cmake, pkg-config, wrapQtAppsHook, qtbase, qtwebsockets, vapoursynth, runCommand, makeWrapper }:
let
  unwrapped = mkDerivation {
    pname = "vapoursynth-editor-sandsmark";
    version = "unstable-2021-01-09";

    src = fetchFromGitHub {
      owner = "sandsmark";
      repo = "vapoursynth-editor";
      rev = "4e3f161c9a213ce46233be3814841591f2bd7b9a";
      sha256 = "05rgkd7ibfr9p560238lq3c9h4x0nm4g48swsz3zp1855db59qx2";
    };

    nativeBuildInputs = [ cmake pkg-config wrapQtAppsHook ];
    buildInputs = [ qtbase qtwebsockets vapoursynth ];

    passthru = { inherit withPlugins; };

    meta = with lib; {
      description = "Cross-platform editor for VapourSynth scripts (sandsmark fork)";
      homepage = "https://github.com/sandsmark/vapoursynth-editor";
      license = with licenses; let
        # not in nixpkgs
        cc-by-25 = {
          spdxId = "CC-BY-2.5";
          fullName = "Creative Commons Attribution 2.5 Generic";
          url = "https://spdx.org/licenses/CC-BY-2.5.html";
        };
      in
        [
          cc-by-25  # Silk icons
          cc-by-30 # FatCow icons
          gpl3Plus # fakevim
          lgpl21Plus # fakevim
          mit
        ];
      maintainers = with maintainers; [ sbruder ];
      platforms = platforms.all;
    };
  };

  withPlugins = plugins: let
    vapoursynthWithPlugins = vapoursynth.withPlugins plugins;
  in runCommand "${unwrapped.name}-with-plugins" {
    buildInputs = [ makeWrapper ];
    passthru = { withPlugins = plugins': withPlugins (plugins ++ plugins'); };
  } ''
    mkdir -p $out/bin
    for bin in vsedit{,-job-server{,-watcher}}; do
        makeWrapper ${unwrapped}/bin/$bin $out/bin/$bin \
            --prefix PYTHONPATH : ${vapoursynthWithPlugins}/${vapoursynth.python3.sitePackages} \
            --prefix LD_LIBRARY_PATH : ${vapoursynthWithPlugins}/lib
    done
  '';
in
  withPlugins []
