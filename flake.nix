{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }:
    let
      inherit (nixpkgs) lib;

      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
      });
    in
    {
      overlays.default = final: prev: {
        {{project-name}} = self.packages.${final.stdenv.system}.{{project-name}};
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          {{project-name}} = default;
          default = pkgs.callPackage ./build.nix { };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              cargo
              rustc
              llvmPackages.lld

              openssl
              pkg-config
              gnumake
              pnpm_10
              wasm-bindgen-cli
            ];
          };
        });
    };
}