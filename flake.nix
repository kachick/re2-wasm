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
          # edge-pkgs = edge-nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              buildInputs = [
                bashInteractive
                nixfmt-rfc-style

                nodejs_20
                cmake
                abseil-cpp # https://github.com/google/re2/blob/b84e3ff189980a33d4a0c6fa1201aa0b3b8bab4a/README#L13
                ninja
                emscripten # `emcc`
              ];
              # LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.abseil-cpp ];
              # propagatedBuildInputs = [ pkgs.abseil-cpp pkgs.icu ];
            };
        }
      );
    };
}
