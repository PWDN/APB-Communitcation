{
  description = "SCK_PRO_2";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {self, nixpkgs, flake-utils, ...}: flake-utils.lib.eachDefaultSystem(system: 
    let
      pkgname = "SCK_PRO_2";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = {
        default = pkgs.callPackage(
          {
            stdenv,
            lib,
          }: stdenv.mkDerivation {
            name = pkgname;
            src = ./.;
            buildInputs = with pkgs; [
              pkg-config
              cmake
              git
            ];
            installPhase = ''
              mkdir -p $out/bin
              cp -r ./${pkgname}  $out/bin/
            '';
          }
        ) {};
      };
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          cmake
          git
          gtkwave
          yosys
          verilog
        ];
      };        
    }
  );
}

