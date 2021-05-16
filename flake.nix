{
  description = "vs-overlay";
  inputs.nixpkgs.url = "github:sbruder/nixpkgs/vapoursynth-improve-dependency-resolution";
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
          config.allowUnfree = true;
        }
      );
    in
    rec {
      overlay = import ./default.nix;
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system})
          getnative
          vapoursynthPlugins;
      });

      # My hydra only has x86_64-linux builders, so only packages from that
      # system are added as hydra jobs
      hydraJobs = {
        x86_64-linux = let
          pkgs = nixpkgsFor.x86_64-linux;
          allPackages = nixpkgs.lib.filterAttrsRecursive
            (k: v: k != "recurseForDerivations")
            packages.x86_64-linux;

          allPlugins = nixpkgs.lib.attrValues allPackages.vapoursynthPlugins;
        in
        allPackages // {
          vapoursynthWithPlugins = pkgs.vapoursynth.withPlugins allPlugins;
          vseditWithPlugins = pkgs.vapoursynth-editor.withPlugins allPlugins;
        };
      };
    };
}
