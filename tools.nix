{ pkgs ? import (builtins.getFlake "git+file://${toString ./.}").inputs.nixpkgs {
    system = builtins.currentSystem;
    config.allowUnfree = true;
  }
# The compiler: the flake's own input, or outside a flake the one its lock names.
, btrc ? builtins.getFlake (builtins.flakeRefToString (builtins.removeAttrs (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.btrc.locked [
    "narHash" "lastModified" "lastModifiedDate" "revCount" "dirtyRev" "dirtyShortRev"
  ]))
}:
(btrc.lib.buildPackage pkgs) {
  name = "proton-sge-tools";
  src = ./tools;
  programs.proton-sge-tools = "Main.btrc";
  runtimeInputs = [ pkgs.nix pkgs.git pkgs.rsync pkgs.coreutils pkgs.diffutils ];
  postInstall = ''
    for command in dev build install make; do
      makeWrapper "$out/bin/proton-sge-tools" "$out/bin/proton-sge-$command" --add-flags "$command"
    done
  '';
}
