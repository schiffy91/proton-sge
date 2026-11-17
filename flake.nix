{
  description = "proton-sge: GE-Proton with a short series of Wine fixes, as a Steam compatibility tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    btrc = { url = "github:schiffy91/btrc"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, btrc }@inputs:
    let
      system = "x86_64-linux";  # the tool is GE-Proton's x86_64 build with rebuilt Wine modules laid over it
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in {
      packages.${system} = rec {
        proton-sge = pkgs.callPackage ./package.nix { inherit (pkgs) makeWrapper rsync unzip; };  # .override { extraFiles } adds 32-bit WineASIO
        tools = import ./tools.nix { inherit pkgs btrc; };  # proton-sge-dev, -build, -install, -make
        default = proton-sge;
      };

      devShells.${system}.default = import ./dev-shell.nix { inherit pkgs; };

      checks.${system} = {  # the tool itself is built by ci/local.json's job `build`
        unit-tools = import ./tests/tools { inherit pkgs inputs; };
        unit-pdb = import ./tests/pdb { inherit pkgs; };
      };
    };
}
