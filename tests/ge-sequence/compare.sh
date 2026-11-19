#!/usr/bin/env bash
# Holds the patches this package applies from GE's tree (ge-sequence.sh) against the ones GE's own script
# applies, in order. Usage: compare.sh <GE's source tree> <ge-sequence.sh>. Exits 1 and prints the
# difference when a patch is missing, extra or out of order.
set -u
shopt -s nullglob
source_tree=$1
sequence=$(realpath "$2")
work=$(mktemp -d)
mkdir -p "$work/wine"
ln -s "$source_tree/patches" "$work/patches"

# GE's list: the Wine section of its script, run with the two patch functions naming what they would
# apply and every other command doing nothing. Its paths are relative to the Wine tree it stands in.
theirs() (
  cd "$work/wine" || exit 1
  apply_patch() { printf '%s\n' "${1#../patches/}" | sed 's|//|/|g'; }
  apply_all_in_dir() {
    local found=0
    for patch in "$1"/*.patch; do found=1; apply_patch "$patch"; done
    [ $found = 1 ] || printf 'EMPTY %s\n' "${1#../}"
  }
  pushd() { :; }; popd() { :; }; git() { :; }; cp() { :; }; mkdir() { :; }; echo() { :; }; autoreconf() { :; }
  command_not_found_handle() { :; }
  source <(sed -n '/^### (2) WINE PATCHING ###/,/^### END WINE PATCHING ###/p' "$source_tree/patches/protonprep-valve-staging.sh") 2> /dev/null
)

# What this package leaves out on purpose. The wine-staging submodule is not in GE's source archive, so
# neither its patch set nor the four patches GE takes from it by hand can be applied; and the OpenXR
# patch needs the wineopenxr sources that GE copies into the tree and this package does not build.
left_out() {
  grep -v -e '^\.\./wine-staging/' -e '^EMPTY wine-staging/' \
    -e '^wine-hotfixes/pending/0001-decouple-wineopenxr-from-steamvr-and-integrate-it-in\.patch$'
}

ours() (
  ge="$source_tree/patches"
  apply_ge() { test -f "$1" || { printf 'MISSING %s\n' "${1#$ge/}"; return; }; printf '%s\n' "${1#$ge/}"; }
  source "$sequence"
)

theirs | left_out > "$work/theirs"
ours > "$work/ours"
[ -s "$work/theirs" ] || { printf 'GE'"'"'s script named no patch: its layout has changed, and this comparison with it\n' >&2; exit 1; }
if diff "$work/theirs" "$work/ours" > "$work/difference"; then
  printf '%s patches, the same as GE'"'"'s script and in its order\n' "$(wc -l < "$work/ours")"
  exit 0
fi
printf 'ge-sequence.sh is not what GE'"'"'s script applies ("<" only GE, ">" only this package):\n' >&2
cat "$work/difference" >&2
exit 1
