{
  rustPlatform,
  lib,
  llvmPackages,
  wasm-bindgen-cli,
  pkg-config,
  openssl,
  stdenvNoCC,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  targetName = "wasm32-unknown-unknown";
  pname = "{{project-name}}";
  version = "0.1.0";

  wasm-build = rustPlatform.buildRustPackage {
    inherit pname version;

    cargoLock.lockFile = ./Cargo.lock;

    src = ./.;

    nativeBuildInputs = [
      wasm-bindgen-cli
      pkg-config
      llvmPackages.lld
    ];

    buildInputs = [
      openssl
    ];

    doCheck = false;

    buildPhase = ''
      runHook preBuild

      cargo build --target ${targetName} --release

      mkdir -p $out/pkg
      wasm-bindgen target/${targetName}/release/{{crate_name}}.wasm --out-dir=$out/pkg

      runHook postBuild
    '';

    installPhase = "echo 'Skipping installPhase'";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  src = ./www;

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  buildPhase = ''
    runHook preBuild

    ln -s ${wasm-build}/pkg ../pkg
    pnpm build
    cp -r dist $out

    runHook postBuild
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = lib.fakeHash;
  };
})
