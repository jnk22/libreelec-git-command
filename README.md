# LibreELEC Git Command

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/jnk22/libreelec-git-command/main.svg)](https://results.pre-commit.ci/latest/github/jnk22/libreelec-git-command/main)
[![LibreELEC supported versions](https://img.shields.io/badge/LibreELEC-10%20%7C%2011%20%7C%2012-blue)](https://libreelec.tv)

This repository provides a `git` executable that wraps a Docker container to
make for [Git](https://git-scm.com/) available on
[LibreELEC](https://libreelec.tv/) devices.

## Usage

First, make sure that you have already installed the [LibreELEC Docker addon](https://github.com/LibreELEC/LibreELEC.tv/blob/master/packages/addons/service/docker/package.mk)
on your LibreELEC device. Then, download the [git wrapper](./git), make it
executable using `chmod +x git` and run it with `./git`!

Alternatively, you can run the `install-git.sh` script that automates the whole
installation process. It installs the Docker addon and Git wrapper, and updates
your `$PATH` to make it available in your shell — just follow the steps in the
next section!

## Installation

To automate the installation of the Docker addon _(if not already installed)_
and the Git wrapper, run:

```bash
curl -sSL https://raw.githubusercontent.com/jnk22/libreelec-git-command/main/install-git.sh | bash
```

_You can also view the script [here](./install-git.sh)._

After installation, the `git` command will be readily available in your
terminal!

## Tested Devices

This solution has been successfully tested on the following devices and
LibreELEC versions:

| Device         | Architecture | LibreELEC Version                          |
| -------------- | ------------ | ------------------------------------------ |
| Intel NUC7JYB  | x86_64       | 11.0.6 _(Kodi 20.3)_, 10.0.2 _(Kodi 19.4)_ |
| Raspberry Pi 3 | arm          | 10.0.2 _(Kodi 19.4)_                       |
| Raspberry Pi 4 | aarch64      | 11.95.1 _(Kodi 21.0 RC1)_                  |

_Please note that this list is not exhaustive, and the Git wrapper and
installation script should work on any device that runs LibreELEC and supports
[containers](https://wiki.libreelec.tv/installation/docker)._

## Development

Development requires the following tools to be installed:

- [Bash](https://www.gnu.org/software/bash/)
- [Docker](https://www.docker.com/)
- [shellspec](https://github.com/shellspec/shellspec)

### Tests

Run tests with:

```bash
shellspec
```

> [!NOTE]
> Tests must be executed within the cloned repository's main directory to
> ensure that tests are run with the actual `git` wrapper.

## Acknowledgments

This repository was initially based on the forum post [Installation of git on
Libreelec@LibreELEC
Forum](https://forum.libreelec.tv/thread/13874-installation-of-git-on-libreelec/?postID=105152#post105152).
While the forum post also builds a custom image, this repository uses pre-built
images instead.
