# Thurstylark's Crestron Helper Scripts: bash

The goal of these scripts is to provide tooling for dealer-level configuration and management of Crestron equipment using existing GNU userspace tools, thus enabling further OS-independent scripting and extension.

## Environment
These scripts are intended to be added to, or sourced by `.bashrc`. The way I implement this in my own environment is detailed [here.](https://git.thurstylark.com/vcsh/bashrc.git/tree/.bashrc?id=f6219cb8944cee6cd1826b8d6f7529742c01c2d1#n39)

My current `.bashrc` can always be found at https://git.thurstylark.com/vcsh/bashrc.git/tree/.bashrc

I normally use these scripts from within Windows Subsystem for Linux (WSL), but they should work in any environment that includes a fairly recent version of bash, and has access to each tool's dependencies. Refer to the appropriate section of this document for each tool's requirements.

----
## cnssh.sh: SSH wrapper
### Usage

Summary:

`cnssh <ip address> [command]`

"Interactive" mode:

`cnssh <ip address>`

"Single command" mode:

`cnssh <ip address> <command>`

NOTE: There are not any "modes" formalized in this script. Rather, it effectively wraps the ssh command. This allows the option of running single commands without the need to directly interact with the device's shell (which is, to be honest, very shit).

### Examples
NOTE: Most of these examples assume that a fairly standard set of GNU userspace tools are present.

Run the same command on multiple devices:

`for i in 121 122 123 124 125; do cnssh 192.168.0.$i <command>; done`

Retrieve a list of all commands, using `less` to enable scrolling and searching:

`cnssh <ip address> help all | less`

Alternatively, save the help contents to a text file:

`cnssh <ip address> help all > commands.txt`

Show all commands that *are* listed by `hidhelp all`, but are *not* listed by `help all`:

`target=<ip address>; comm -23 <(cnssh $target hidhelp all | sort) <(cnssh $target help all | sort) | less`

### Details

`cnssh` is built to be a stupid-simple wrapper for ssh, using `sshpass` to bypass the interactive password prompt with a blank password. 

Many of the other scripts in the bash folder depend on this script for communication to the target device.

This function uses the following SSH options:
- `StrictHostKeyChecking=no`
  - Keeps SSH from checking for the host key based on hostname/ip address
  - This allows the user to connect to different devices that happen to use the same hostname/ip without needing to edit `~/.ssh/known_hosts` for every new connection
- `GlobalKnownHostsFile=/dev/null`
  - This forces SSH to throw away any host key information that it would otherwise keep to do host key checking
- `UserKnownHostsFile=/dev/null`
  - Same as above, but at the user level
- `LogLevel=ERROR`
  - Suppress any message that is WARNING level or below from going to stderr
  - Specifically added for removing a warning about adding a host to the known hosts file which has been effectively disabled
- `User=Crestron`

This script assumes that authentication has not been set up on the target device. If a username and password are required, the script must be modified to either include the necessary credentials (not recommended), or to exclude the use of `sshpass`, and use the interactive password prompt. 

Alternatively, public key authentication can be set up to bypass the need for the interactive password prompt altothether, but this method remains entirely untested.

----
## cnsftp.sh: SFTP wrapper
### Usage

Summary:

`cnsftp <sftp options>`

Interactive mode:

`cnsftp <ip address>`

Refer to `sftp`'s manpage for more usage information.

### Examples

Upload `project.lpz` to `/Program01/`:

`printf 'put %q' ./project.lpz | cnsftp <ip address>:Program01`

Download `/USER/settings.ini` from target device:

`printf 'get settings.ini' | cnsftp <ip address>:USER`

See `cn-progload.sh` and `cn-fwupd.sh` for more implementation examples.

### Details

`cnsftp` is yet another (somehow even stupider) wrapper in the same vein as `cnssh`, but for sftp instead. It uses the same list of ssh options as `cnssh`, and `sshpass` for bypassing the interactive password prompt. 

The entire command line after `cnssh` is passed directly to `sftp` without modification. This way, `cnsftp` can act as a drop-in replacement for `sftp` (which, in turn, can be used as a replacement for `ftp`). 

While this file transfer solution is easy to implement, it is far from ideal. This is specifically due to Crestron's continued reliance on FTP as a transfer protocol, and the inability to install any other file transfer tools that use SSH as transport. Since Crestron did the bare minimum implementation of ssh and sftp (ostensibly to get their JITC certification), the available feature set is greatly lacking compared to a standard GNU userspace, so we're stuck with ftp or sftp for file transfer. 

This specific reason was my main motivation for writing `cn-progload.sh` and `cn-fwupd.sh`; Syntax for sending one file, in either direction, via sftp with one line is absolutely rediculous. 

In the future, I plan on writing more wrappers for `cnsftp` to make file transfers easier.

----
## cn-fwupd.sh: Send firmware to a device, and begin direct update
### Usage

Summary:

`cn-fwupd <ip address> <file>`

### Examples

Update multiple units (of the same model) at once:

`for i in 10 11 12 13 14; do cn-fwupd 192.168.0.$i /path/to/update.puf; done`

### Details

`cn-fwupd` wraps `cnsftp` and `cnssh` with some minimal logic to handle firmware files of different types. It checks the file extension, uploads the file to the firmware folder, and then runs the appropriate program to perform the update on the device. 

The only check in this script is for the file extension. It assumes that you gave it the right file for the model you are targeting, and will upload the file to the target device's storage as long as it connects. Once the file transfer is complete, the script will start either `puf` (if the provided file has an extension of .puf), or `pushupdate FULL` (if the provided file has an extension of .zip). 

**NOTE: This script lacks any checks for file integrity, model number, and a whole slew of other corner cases that could get one into trouble, and as such, should probably not be used unless you know what you're doing.**

Currently this script has only been tested on a DMPS3-4K-150-C, and a TSW-760. From experience, this should cover most 3-Series controllers, touchpanels and DMPSs, but I assume that I will need to add tweaks to this script as I encounter different models in the field. 

----
## cn-progload.sh: Send and load a compiled project to a controller or touchpanel
### Usage

Summary:

`cn-progload <ip address> <file> [slot]`

### Examples

Load a touchpanel:

`cn-progload <ip address> /path/to/compiled.vtz`

Load a compiled SIMPL Windows project to a controller's slot 1:

`cn-progload <ip address> /path/to/compiled.lpz`

Load a compiled SIMPL Windows project to a controller's slot 2:

`cn-progload <ip address> /path/to/compiled.lpz 2`

Load multiple touchpanels with the same project:

`for i in 10 11 12 13 14; do cn-progload 192.168.0.$i /path/to/compiled.vtz; done`

### Details

`cn-progload` wraps `cnsftp` and `cnssh` with some minimal logic for handling different file types, and for determining the target program slot. It checks the file extension, and uses the provided slot information to upload the compiled project to the target device. It then uses the appropriate command to load the project to the device.

If the file provided has an extension of .vtz, this script will ignore the slot number (if provided), upload the file to `display/`, and run `projectload` on the target device.

If the file provided has an extension of .lpz, this script will upload the file to the provided slot number (or slot 1 if not defined on the command line), and run `progload -p:$slot` on the target device.

**NOTE: This script lacks any checks for file integrity, model number, and a whole slew of other corner cases that could get one into trouble, and as such, should probably not be used unless you know what you're doing.**

Currently this script has only been tested on a DMPS3-4K-150-C, and a TSW-760. From experience, this should cover most 3-Series controllers, touchpanels and DMPSs, but I assume that I will need to add tweaks to this script as I encounter different models in the field. 
