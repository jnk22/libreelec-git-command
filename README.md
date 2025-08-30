# Git for LibreELEC via Docker

[![version](https://img.shields.io/github/v/tag/jnk22/libreelec-git-command?sort=semver)](https://github.com/jnk22/libreelec-git-command/releases)
[![LibreELEC supported versions](https://img.shields.io/badge/LibreELEC-10%20%7C%2011%20%7C%2012-blue)](https://libreelec.tv)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/jnk22/libreelec-git-command/main.svg)](https://results.pre-commit.ci/latest/github/jnk22/libreelec-git-command/main)
[![ci](https://github.com/jnk22/libreelec-git-command/actions/workflows/ci.yaml/badge.svg)](https://github.com/jnk22/libreelec-git-command/actions/workflows/ci.yaml)

This project provides a `git` command wrapper that runs
[Git](https://git-scm.com/) inside a Docker container, enabling its use on
[LibreELEC](https://libreelec.tv/) devices.

## Usage

First, install the [LibreELEC Docker addon](https://github.com/LibreELEC/LibreELEC.tv/blob/master/packages/addons/service/docker/package.mk)
on your LibreELEC device. Then download the [git wrapper](./git), make it
executable, and run:

```bash
./git
```

**Recommended:** Use the automated installation script, which installs the
Docker addon (if not already installed), sets up the Git wrapper, and updates
your `$PATH`:

```bash
curl -fsSL https://raw.githubusercontent.com/jnk22/libreelec-git-command/main/install.sh | sh
```

After installation, you may need to log out and log back in, or run:

```bash
source ~/.profile
```

Once complete, the `git` command will be available in your terminal.

> [!NOTE]
> The initial run may take longer because Docker needs to pull the specified
> Git container image if it is not already cached locally.

### Additional Parameters

| Parameter       | Description                                                                                | Default                             |
| --------------- | ------------------------------------------------------------------------------------------ | ----------------------------------- |
| `IMAGE_NAME`    | Docker image name to use for the Git container.                                            | `alpine/git`                        |
| `IMAGE_TAG`     | Docker image tag to use.                                                                   | `latest`                            |
| `DOCKER_OPTS`   | Additional Docker options passed to the `docker run` command.                              | Automatically detected or empty     |
| `SSH_AUTH_SOCK` | Path to SSH agent socket on the host, mounted inside the container for SSH authentication. | Automatically detected if available |

**Example:**

```bash
IMAGE_NAME="bitnami/git" IMAGE_TAG="2.50.1" git version
# Output:
# git version 2.50.1
```

## Tested Devices

Confirmed working on the following devices and LibreELEC versions:

| Device         | Architecture | LibreELEC Version                                                |
| -------------- | ------------ | ---------------------------------------------------------------- |
| Intel NUC7JYB  | x86_64       | 12.0.2 _(Kodi 21.2)_, 11.0.6 _(Kodi 20.3)_, 10.0.2 _(Kodi 19.4)_ |
| Raspberry Pi 3 | arm          | 10.0.2 _(Kodi 19.4)_                                             |
| Raspberry Pi 4 | aarch64      | 11.95.1 _(Kodi 21.0 RC1)_                                        |

_This list is not exhaustive. The wrapper should work on any LibreELEC device
that supports [Docker containers](https://wiki.libreelec.tv/installation/docker).
Contributions with additional tested devices are welcome._

## Development

To contribute, install the following tools:

- [Bash](https://www.gnu.org/software/bash/) — shell scripting environment
- [Docker](https://www.docker.com/) — container runtime
- [ShellSpec](https://github.com/shellspec/shellspec) — testing framework for
  shell scripts
- _(Optional)_ [kcov](https://github.com/SimonKagstrom/kcov) — for generating
  coverage reports

> [!NOTE]
> Bash arrays cannot be used because LibreELEC uses
> [BusyBox](https://busybox.net/source.html) for its shell, which does not
> support arrays.

### Running Tests

Run tests from the repository root directory to ensure they execute with the
correct `git` wrapper:

```bash
shellspec
```

To generate a coverage report:

```bash
shellspec --kcov --kcov-options "--include-pattern=/git"
```

### Versioning

This repository uses [Bump My Version](https://pypi.org/project/bump-my-version/)
to manage version numbers and changelog updates.

- Version numbers follow [Semantic Versioning](https://semver.org/).
- Changelog entries are maintained in `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
  format.
- To bump a version, run:

```bash
bump-my-version bump minor  # or major/patch
```

After bumping a release, prepare the next development
cycle by adding a fresh [Unreleased] section and link.
This script will also commit the update automatically:

```bash
./scripts/prepare-next-version.sh
```

## Acknowledgments

This project was initially inspired by the forum post
[Installation of git on LibreELEC@LibreELEC Forum](https://forum.libreelec.tv/thread/13874-installation-of-git-on-libreelec/?postID=105152#post105152).
While the forum method builds a custom image, this project uses pre-built
images for convenience.
