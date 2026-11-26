# LD06 outdoor filter for ArduPilot

**[How to build your own firmware with it: step by step](BUILD.md)**

The stock ArduPilot LD06 driver reports fake obstacles all around the vehicle outdoors in daylight.
These patches replace its filter with LDROBOT's own filter over the full 12 m range, plus a check that small objects are seen on two sweeps.
Details, test results and trade-offs: [ArduPilot PR #35396](https://github.com/ArduPilot/ardupilot/pull/35396).

This branch is only the kit. The code itself is the PR branch [`ld06-outdoor-filter`](https://github.com/JoshuaDodds/ardupilot/tree/ld06-outdoor-filter).

## What's here

| | |
|---|---|
| [`BUILD.md`](BUILD.md) | Step by step: build a firmware for a new ArduPilot release with the patches |
| `apply_and_build.sh` | Does it all: gets the release, applies the patches, builds, copies the `.apj` to `out/` |
| `patches/` | The 6 commits of the PR, as patch files |

## When the patches stop applying

The script stops with "the patches do not apply" when upstream changed the LD06 driver.

1. Check whether the release already has the fix (if PR #35396 was merged, a plain release is enough and you don't need this kit).
2. Otherwise rebase the PR branch on the new release and export the patches again:

```
cd ~/ardupilot
git fetch origin tag <new release tag>
git fetch https://github.com/JoshuaDodds/ardupilot.git ld06-outdoor-filter
git checkout -B ld06-outdoor-filter FETCH_HEAD
git rebase --onto <new release tag> HEAD~6     # fix conflicts in AP_Proximity_LD06.cpp/.h if any
rm ~/ld06-kit/patches/*.patch
git format-patch -o ~/ld06-kit/patches <new release tag>..HEAD
```

Then commit the new patch files to this branch and push.
