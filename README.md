# LibreELEC Git Command

This script makes it possible to use the command `git` on LibreELEC Kodi installations, where this is usually not possible.

This solution is based on a forum post in the thread [Installation of git on Libreelec@LibreELEC Forum](https://forum.libreelec.tv/thread/13874-installation-of-git-on-libreelec/?postID=105152#post105152).

## Installation

The installation script requires the Kodi service addon **Docker** from *Team LibreELEC* to be installed on your Kodi system.
If not installed, this script automatically tries to install the addon, but requires a manual confirmation.

To install, run:

```shell
curl -sSL https://raw.githubusercontent.com/jnk22/libreelec-git-command/main/install-git.sh | bash
```

You can now use the command `git` in your terminal!

*This has only been tested with **LibreELEC 10.0.2** (Kodi 19.4) on a Raspberry Pi 3.*
