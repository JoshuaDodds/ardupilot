#!/bin/bash
# Apply the LD06 outdoor filter patches to an ArduPilot release and build it.
#
# usage:  ./apply_and_build.sh <release> [board]
#   release  an ArduPilot tag or branch, e.g. Copter-4.7.4 or master
#   board    default MatekH743-bdshot
#
# The ArduPilot clone used is $AP_DIR (default ~/ardupilot); it is cloned if
# it does not exist. Each release gets its own branch there, ld06-<release>.
# The finished .apj is copied to ./out next to this script.
set -euo pipefail

REL=${1:?usage: ./apply_and_build.sh <release, e.g. Copter-4.7.4> [board]}
BOARD=${2:-MatekH743-bdshot}
KIT=$(cd "$(dirname "$0")" && pwd)
AP=${AP_DIR:-$HOME/ardupilot}

if [ ! -d "$AP/.git" ]; then
    echo "== cloning ArduPilot into $AP"
    git clone https://github.com/ArduPilot/ardupilot.git "$AP"
fi
cd "$AP"

if ! git diff --quiet --ignore-submodules || ! git diff --cached --quiet --ignore-submodules; then
    echo "ERROR: $AP has uncommitted changes. Commit or stash them first." >&2
    exit 1
fi

echo "== getting $REL"
git fetch origin "$REL"
git checkout -B "ld06-$REL" FETCH_HEAD
git submodule update --init --recursive

echo "== applying the LD06 patches"
# git am needs a name for the commits it makes; use the clone's own if set
if [ -z "$(git config user.email || true)" ]; then
    export GIT_COMMITTER_NAME="ld06-kit" GIT_COMMITTER_EMAIL="ld06-kit@localhost"
fi
if ! git am --3way "$KIT"/patches/*.patch; then
    git am --abort || true
    echo >&2
    echo "ERROR: the patches do not apply to $REL." >&2
    echo "The LD06 driver changed upstream. Check whether $REL already contains" >&2
    echo "the fix (PR 35396), otherwise the patches need updating, see README." >&2
    exit 1
fi

echo "== building $BOARD"
./waf configure --board "$BOARD"
./waf clean    # objects from another release in the same build folder break the build
./waf copter

HASH=$(git rev-parse --short=8 HEAD)
mkdir -p "$KIT/out"
OUT="$KIT/out/arducopter_${REL}_LD06_${BOARD}_${HASH}.apj"
cp "build/$BOARD/bin/arducopter.apj" "$OUT"

echo
echo "Done: $OUT"
echo "After flashing, the boot banner must end in ($HASH)."
