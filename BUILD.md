# Build a firmware with the LD06 patches

For Windows with WSL (Ubuntu). On a plain Ubuntu machine skip step 0.
Steps 0 to 2 are only needed once.

## 0. Ubuntu on Windows (once)

In PowerShell: `wsl --install -d Ubuntu`, reboot, open "Ubuntu" from the Start menu and pick a user name and password.
Everything below is typed in that Ubuntu window.

## 1. ArduPilot and its build tools (once, takes a while)

```
git clone --recurse-submodules https://github.com/ArduPilot/ardupilot.git ~/ardupilot
cd ~/ardupilot
Tools/environment_install/install-prereqs-ubuntu.sh -y
```

Close the Ubuntu window and open a new one, so the build tools are found.

## 2. This kit (once)

```
git clone --single-branch -b ld06-kit https://github.com/JoshuaDodds/ardupilot.git ~/ld06-kit
```

(`--single-branch` matters: it downloads only this small kit, not all of ArduPilot again.)

## 3. Build for a release

Find the release name on https://github.com/ArduPilot/ardupilot/tags, for example `Copter-4.7.4`. Then:

```
cd ~/ld06-kit
git pull                                  # get the latest patches
./apply_and_build.sh Copter-4.7.4         # your MatekH743-bdshot
./apply_and_build.sh Copter-4.7.4 <board> # any other board name
```

It takes about 10 minutes the first time for a release. At the end it prints where the file is, for example
`~/ld06-kit/out/arducopter_Copter-4.7.4_LD06_MatekH743-bdshot_1a2b3c4d.apj`, and the hash the boot banner will show.

If it says **the patches do not apply**, see the bottom of the [README](README.md).

## 4. Flash it

1. In Windows Explorer the file is at `\\wsl$\Ubuntu\home\<your ubuntu user>\ld06-kit\out\`.
2. Mission Planner, Setup, Install Firmware, **Load custom firmware**, pick the `.apj`.
3. Never "update bootloader", never a `_with_bl.hex`.
4. Reconnect and check the banner in Messages: `ArduCopter V4.7.4 (1a2b3c4d)` with the hash the script printed.

Keep the firmware you had before, so you can go back.

## 5. Before flying

- The proximity view shows walls where they are.
- No `LD06 turning too slowly` message.
- First flight: a few slow wall approaches in Loiter, with Stabilize as the escape.

These builds don't have the raw packet logging (LD6R) that the test builds had.
