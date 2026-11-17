{ pkgs, inputs }:
let
  programs = (inputs.btrc.lib.buildPackage pkgs) {
    name = "proton-tools-contract-tests";
    src = (import ../lib/test-source.nix { inherit pkgs inputs; }) {
      root = ../..;
      fileset = pkgs.lib.fileset.unions [ ../../tools ./ToolsTests.btrc ./Integration.btrc ./CommandFixture.btrc ./btrc.toml ./btrc.lock ];
    };
    programs = {
      proton-sge-tools = "tools/Main.btrc";
      proton-tools-test = "tests/tools/ToolsTests.btrc";
      proton-tools-integration = "tests/tools/Integration.btrc";
      proton-command-fixture = "tests/tools/CommandFixture.btrc";
    };
  };
in pkgs.runCommand "proton-tools-contract-check" {
  nativeBuildInputs = [ pkgs.rsync pkgs.coreutils pkgs.git pkgs.diffutils ];
} ''
  ${programs}/bin/proton-tools-test
  ${programs}/bin/proton-tools-integration ${programs}/bin/proton-sge-tools ${programs}/bin/proton-command-fixture
  touch "$out"
''
