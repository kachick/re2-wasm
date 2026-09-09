{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              buildInputs = [
                bashInteractive
                nixfmt
                nil

                nodejs_22
                gnumake
                cmake
                ninja
                emscripten
              ];

              shellHook = ''
                export ABSEIL_SOURCE_DIR="${pkgs.abseil-cpp_202401.src}"
              '';
            };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          re2-src = pkgs.fetchFromGitHub {
            owner = "google";
            repo = "re2";
            rev = "2024-07-02";
            hash = "sha256-IeANwJlJl45yf8iu/AZNDoiyIvTCZIeK1b74sdCfAIc=";
          };
        in
        rec {
          re2-wasm = pkgs.stdenv.mkDerivation {
            pname = "re2-wasm";
            version = "2024-07-02";

            src = ./.;

            dontUseCmakeConfigure = true;

            nativeBuildInputs = with pkgs; [
              cmake
              ninja
              emscripten
            ];

            buildPhase = ''
              export HOME=$TMPDIR
              export EM_CACHE=$TMPDIR/emcache

              mkdir -p deps
              rm -rf deps/re2
              cp -r ${re2-src} deps/re2
              chmod -R u+w deps/re2

              emcmake cmake -B build/cmake -G Ninja \
                -DCMAKE_BUILD_TYPE=Release \
                -DABSEIL_SOURCE_DIR=${pkgs.abseil-cpp_202401.src}

              cmake --build build/cmake --target re2_wasm
            '';

            installPhase = ''
              mkdir -p $out/lib/wasm
              cp build/cmake/re2.js $out/lib/wasm/
              cp build/cmake/re2.wasm $out/lib/wasm/
            '';
          };
          default = re2-wasm;
        }
      );
    };
}
