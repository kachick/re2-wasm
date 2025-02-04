{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # edge-nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    # edge-nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        # edge-pkgs = edge-nixpkgs.legacyPackages.${system};
        {
          default =
            with pkgs;
            mkShell {
              buildInputs = [
                bashInteractive
                nixfmt-rfc-style
                nil

                nodejs_20
                cmake
                # abseil-cpp # https://github.com/google/re2/blob/b84e3ff189980a33d4a0c6fa1201aa0b3b8bab4a/README#L13
                (abseil-cpp_202401.override { cxxStandard = "17"; })
                ninja
                llvmPackages_17.clang-tools
                emscripten # `emcc`
              ];
              # LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.abseil-cpp ];
              # propagatedBuildInputs = [ pkgs.abseil-cpp pkgs.icu ];
            };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          my-abseil = pkgs.abseil-cpp_202401.override { cxxStandard = "17"; };

          re2-src = pkgs.fetchgit {
            url = "git://github.com/google/re2.git";
            rev = "2024-07-02";
            hash = lib.fakeHash;
            fetchSubmodules = true;
          };
        in
        {
          re2-wasm = pkgs.llvmPackages_17.stdenv.mkDerivation {
            name = "re2-wasm";
            srcs = [
              ./.
              re2-src
            ];
            # nativeBuildInputs = with pkgs; [
            #   # gnumake
            #   cmake
            #   # ninja
            #   # pkg-config
            #   my-abseil
            #   llvmPackages_17.clang-tools
            # ];
            buildInputs = with pkgs; [
              llvmPackages_17.clang-tools

              nodejs_20
              # gnumake
              cmake

              # ninja
              my-abseil
              emscripten # `emcc`
            ];

            # buildPhase = ''

            # '';

            installPhase = ''
              rm -rf ./deps
              mv ./re2 ./deps/re2
              npm install
            '';
          };
        }
      );
    };
}
