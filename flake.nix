{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
	inputs.rtos-nix.url = "github:ZainKergayeProjects/rtos.nix";
  inputs.rtos-nix.inputs.nixpkgs.follows = "nixpkgs";
	inputs.unity= {
    url = "git+https://github.com/ThrowTheSwitch/Unity.git";
    flake = false;
  };


  outputs =
    {
      self,
      nixpkgs,
      rtos-nix,
			unity,
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
      packages = forAllSystems (
        system: {
          default = pkgs.${system}.stdenv.mkDerivation {
            name = "lab00";
            src = ./.;
            buildInputs = with pkgs.${system}; [
              cmake
              git
              gcc-arm-embedded
              python3
							rtos-nix.packages.${system}.pico-sdk-overriden
              picotool
							unity-test
            ];
            phases = [ "installPhase" ];
            installPhase = ''
							export PICO_SDK_PATH=${rtos-nix.packages.${system}.pico-sdk-overriden}/lib/pico-sdk
							export FREERTOS_PATH=${rtos-nix.freertos}
							export OPENOCD_PATH=${pkgs.${system}.openocd}
							export UNITY_PATH=${unity}
							mkdir -p $out
							cmake -B $out -S $src/
							cd $out
							cmake --build . --target all
            '';
          };

        }
      );

      devShells = forAllSystems (system: {
        default = rtos-nix.devShells.${system}.default;
      });
    };
}
