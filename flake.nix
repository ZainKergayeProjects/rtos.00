{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.rtos-nix.url = "github:ZainKergayeProjects/rtos.nix";
  inputs.rtos-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      rtos-nix,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: {
        default = pkgs.${system}.stdenv.mkDerivation {
          name = "lab00";
          src = ./.;
          buildInputs = with pkgs.${system}; [
            cmake
            gcc-arm-embedded
          ];
          phases = [ "installPhase" ];
          installPhase = ''
						mkdir -p $out
						cmake -B $out -S $src/
						cd $out
						cmake --build . --target all
          '';
        };

      });

      devShells = forAllSystems (system: {
        default = rtos-nix.devShells.${system}.default;
      });
    };
}
