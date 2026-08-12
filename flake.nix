{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forAllSystems = nixpkgs.lib.genAttrs systems;
      define = f: forAllSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = define (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            alire
            gnat14
            gnat14Packages.gprbuild
            unzip
          ];
        };
      });
    };
}
