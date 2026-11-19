# The Wine modules this package overlays must be built from the tree GE built its own from, so the list
# of GE's patches it applies, written out by hand in ge-sequence.sh, is held against GE's own script.
# A patch left out and two patches in the wrong order are seeded here, and each must be caught.
{ pkgs, protonSge }:
pkgs.runCommand "ge-sequence" { nativeBuildInputs = [ pkgs.diffutils pkgs.gnused pkgs.gnugrep ]; } ''
  compare() { bash ${./compare.sh} ${protonSge.wineSource.geProtonSrc} "$1"; }
  compare ${../../ge-sequence.sh}

  sed 's/ ntdll-remove-redundant-packed-split-lock / /' ${../../ge-sequence.sh} > omitted.sh
  ! cmp -s omitted.sh ${../../ge-sequence.sh}
  if compare omitted.sh > omitted.out 2>&1; then echo "a left-out patch was not caught"; exit 1; fi
  grep -q '^< wine-hotfixes/pending/ntdll-remove-redundant-packed-split-lock.patch$' omitted.out

  sed 's/assettocorsa-hud pso2_hack/pso2_hack assettocorsa-hud/' ${../../ge-sequence.sh} > swapped.sh
  ! cmp -s swapped.sh ${../../ge-sequence.sh}
  if compare swapped.sh > swapped.out 2>&1; then echo "two patches in the wrong order were not caught"; exit 1; fi
  touch $out
''
