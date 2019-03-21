{
  purescript ? "0.12.3",
  nixjs-version ? "0.0.8",
  nixjs ? fetchTarball "https://github.com/cprussin/nixjs/archive/${nixjs-version}.tar.gz",
  nixpkgs ? <nixpkgs>
}:

let
  nixjs-overlay = import nixjs { purescript = purescript; };
  pkgs = import nixpkgs { overlays = [ nixjs-overlay ]; };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.nodejs
    pkgs.yarn
    pkgs.purescript
    pkgs.psc-package
  ];
}
