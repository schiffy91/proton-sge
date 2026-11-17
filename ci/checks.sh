#!/usr/bin/env bash
# Builds the flake checks of this system in one nix invocation and names the ones that fail.
#   ci/checks.sh        every check
#   ci/checks.sh unit   the checks named unit-*: a program is built and run
#   ci/checks.sh unit   is all there is here: the tool itself is built by the job `build` of ci/local.json
# A list that cannot be read, or is empty, is a failure: nothing built must never read as a pass.
set -u
cd "$(dirname "$0")/.." || exit 1
kind=${1:-}
system=$(nix eval --raw --impure --expr builtins.currentSystem) || { printf 'cannot read the current system\n' >&2; exit 1; }
names=$(nix eval --raw ".#checks.$system" --apply 'checks: builtins.concatStringsSep "\n" (builtins.attrNames checks)') || { printf 'cannot list the checks of %s\n' "$system" >&2; exit 1; }
if [ -n "$kind" ]; then names=$(printf '%s\n' "$names" | grep "^$kind-"); fi
[ -n "$names" ] || { printf 'no %s checks are listed for %s\n' "${kind:-flake}" "$system" >&2; exit 1; }
printf '%s\n' "$names"
installables=()
for name in $names; do installables+=(".#checks.$system.$name"); done
nix build --no-link --print-build-logs --keep-going "${installables[@]}" && exit 0
failed=""
for name in $names; do  # everything that passed is already built, so this only names the failures
  nix build --no-link ".#checks.$system.$name" > /dev/null 2>&1 || failed="$failed $name"
done
printf '\nfailed:%s\n' "$failed"
exit 1
