{ pkgs ? import (builtins.getFlake "git+file://${toString ./.}").inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  }
, target ? "64"
, protonRoot ? toString ./.
}:

let
  shellHook = ''
    export PROTON_SGE_IN_DEV_SHELL=1
    export PROTON_SGE_ROOT="${protonRoot}"
    export PROTON_SGE_DEV_ROOT="${protonRoot}/src"
    export PROTON_SGE_WINE_SRC="$PROTON_SGE_DEV_ROOT/wine"
    export PROTON_SGE_WINE64_BUILD="$PROTON_SGE_DEV_ROOT/wine64"
    export PROTON_SGE_WINE32_BUILD="$PROTON_SGE_DEV_ROOT/wine32"
    export PROTON_SGE_JOBS="''${PROTON_SGE_JOBS:-$(nproc)}"
    mkdir -p "$PROTON_SGE_DEV_ROOT"

    if [ "''${PROTON_SGE_QUIET_SHELL:-}" = 1 ]; then
      return
    fi

    cat <<EOF
proton-sge dev shell
  sources: $PROTON_SGE_DEV_ROOT
  loop:    make setup | make wayland | make win32u | make ntdll
  helper:  proton-sge-make <target> works from any directory
EOF
  '';

  commonPackages = with pkgs; [
    (import ./tools.nix { inherit pkgs; })
    autoconf
    automake
    bison
    dotool
    flex
    glslang
    git
    gnumake
    imagemagick
    kdotool
    meson
    ninja
    perl
    pkg-config
    python3
    umu-launcher
    wayland-scanner
    pkgsCross.mingwW64.buildPackages.gcc
    pkgsCross.mingw32.buildPackages.gcc
  ];

  buildInputs64 = with pkgs; [
      dbus
      fontconfig
      freetype
      libGL
      libxkbcommon
      mesa
      vulkan-headers
      vulkan-loader
      wayland
      libx11
  ];

  buildInputs32 = with pkgs.pkgsi686Linux; [
      dbus
      fontconfig
      freetype
      libGL
      libxkbcommon
      mesa
      vulkan-loader
      wayland
      libx11
  ];
in
if target == "32" then
  pkgs.pkgsi686Linux.mkShell {
    packages = commonPackages;
    buildInputs = buildInputs32;
    inherit shellHook;
  }
else
  pkgs.mkShell {
    packages = commonPackages;
    buildInputs = buildInputs64;
    inherit shellHook;
  }
