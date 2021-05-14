{
  description = "vs-overlay";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        # Hydra is confused by recurseForDerivations attributes
        x86_64-linux = nixpkgs.lib.filterAttrsRecursive
          (k: v: k != "recurseForDerivations")
          packages.x86_64-linux;
      };
    };
}
