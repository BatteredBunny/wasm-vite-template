{ pkgs, rustPlatform, makeRustPlatform, mkYarnPackage, fetchYarnDeps }: let
    targetName = "wasm32-unknown-unknown";

    wasm-rust = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
        targets = [ targetName ];
    };

    rustPlatformWasm = makeRustPlatform {
        cargo = wasm-rust;
        rustc = wasm-rust;
    };

    wasm-build = rustPlatformWasm.buildRustPackage rec {
          name = "{{project-name}}";
          cargoLock.lockFile = ./Cargo.lock;

          src = ./.;

          nativeBuildInputs = with pkgs; [
            wasm-bindgen-cli
          ];

          buildInputs = with pkgs; [
            openssl
            pkg-config
            gnumake
          ];

          buildPhase = ''
            cargo build --target ${targetName} --release
            wasm-bindgen target/${targetName}/release/{{crate_name}}.wasm --out-dir=$out/pkg
          '';

          installPhase = "echo 'Skipping installPhase'";
    };
in
mkYarnPackage rec {
    src = ./www;

    offlineCache = fetchYarnDeps {
        yarnLock = src + "/yarn.lock";
        hash = "sha256-SrYZ9s5gjKMINx8sNTIDzVsxUD1F4bFvWR+C8x08jdY=";
    };

    buildPhase = ''
        ln -s ${wasm-build}/pkg ../pkg
        export HOME=$(mktemp -d)
        yarn --offline build
        cp -r dist $out
    '';

    doDist = false;

    configurePhase = ''
        ln -s $node_modules node_modules
    '';

    installPhase = "echo 'Skipping installPhase'";
}