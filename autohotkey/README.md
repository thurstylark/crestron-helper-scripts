# Thurstylark's Crestron Helper Scripts: AutoHotKey

The goal of these scripts is to make Crestron's GUI tools less annoying to use.

----
## simpl-windows-tweaks.ahk: Additional keyboard functionality for SIMPL Windows
### Usage
1. Install AutoHotKey
2. Download this script and `paris-functions.ahk` to the same directory
3. Launch this script as administrator
4. Launch SIMPL Windows

### Details

`simpl-windows-tweaks.ahk` is an AutoHotKey script for adding keyboard functionality that is either missing or stupidly implemented in SIMPL Windows

Refer to the script's comments for details about what functionality has been added and how it is implemented.

The entirety of the functional part of this script will only work if `smpwin.exe` is in the foreground. 

Since Windows will not allow a non-admin process to read info from, or send keypresses to an admin process, this script must also be an administrator. Because SIMPL Windows insists on running as an administrator, this script must also be run as administrator, or it will do nothing. 

Luckily, the launch order does not seem to matter, so this script can be launched after SIMPL Windows is already running.
