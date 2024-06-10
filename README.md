# LibreELEC Git Command

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/jnk22/libreelec-git-command/main.svg)](https://results.pre-commit.ci/latest/github/jnk22/libreelec-git-command/main)
[![LibreELEC supported versions](https://img.shields.io/badge/LibreELEC-10%20%7C%2011%20%7C%2012-blue)](https://libreelec.tv)

This script installs [Git](https://git-scm.com/) within a Docker container on
[LibreELEC](https://libreelec.tv/) devices, enabling usage of `git` commands.

It is based on a forum post found in the thread
[Installation of git on Libreelec@LibreELEC Forum](https://forum.libreelec.tv/thread/13874-installation-of-git-on-libreelec/?postID=105152#post105152).

## Installation

The installation script relies on the Kodi service addon **Docker** from _Team
LibreELEC_ to be installed on your Kodi system.
If not already installed, this script automatically attempts to install the
addon.

To install Git, simply execute the following command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/jnk22/libreelec-git-command/main/install-git.sh | bash
```

You can also access the script directly
[here](https://raw.githubusercontent.com/jnk22/libreelec-git-command/main/install-git.sh).

After installation, the `git` command will be readily available in your
terminal!

## Tested Devices

The script has been successfully tested on the following devices and LibreELEC
versions:

| Device         | Architecture | LibreELEC Version                          |
| -------------- | ------------ | ------------------------------------------ |
| Intel NUC7JYB  | x86_64       | 11.0.6 _(Kodi 20.3)_, 10.0.2 _(Kodi 19.4)_ |
| Raspberry Pi 3 | arm          | 10.0.2 _(Kodi 19.4)_                       |
| Raspberry Pi 4 | aarch64      | 11.95.1 _(Kodi 21.0 RC1)_                  |

_Please note that this list is not exhaustive, and the script should function
correctly on any device that runs LibreELEC and supports
[containers](https://wiki.libreelec.tv/installation/docker)._

## Development

### Requirements

- [Bash](https://www.gnu.org/software/bash/)
- [Docker](https://www.docker.com/)
- [shellspec](https://github.com/shellspec/shellspec)

### Run Tests

Running tests requires [shellspec](https://github.com/shellspec/shellspec) to
be installed on your system.

```bash
shellspec --path ".:$PATH"
```

**Note:**
_The `shellspec` path must be set to the directory that contains the `git`
command wrapper to ensure that the actual wrapper is tested and not a
system-installed executable of Git._

## Contributing

Contributions are welcomed! Feel free to open an issue or a pull request.

This project utilizes pre-commit to maintain code quality.

To set up pre-commit, install it using your preferred package manager and
execute the following commands within the repository:

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

This ensures that your code is linted and formatted before being committed.
