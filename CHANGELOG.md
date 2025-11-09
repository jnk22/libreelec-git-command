# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Mount `~/.git-credentials` from host if available

## [0.3.0] - 2025-08-30

### Fixed

- Git and SSH configs are now correctly mounted into the container

## [0.2.0] - 2025-08-10

### Added

- Allow `git` to interact with absolute host paths (fixes #20)
- Environment variables `IMAGE_NAME` and `IMAGE_TAG` to override Docker image
  and tag
- Support for environment variable `DOCKER_OPTS` to pass options through to the
  Docker container
- Tests for `git` wrapper using
  [ShellSpec](https://github.com/shellspec/shellspec)
- GitHub Actions workflow for automated tests
- Changelog file ([CHANGELOG.md](CHANGELOG.md))

### Changed

- Use pre-built Docker image [alpine/git](https://hub.docker.com/r/alpine/git)
  instead of manual build
- Renamed installation script to `install.sh`
- Set working directory to `$PWD` and mount `$PWD:$PWD` for improved path
  handling and user output
- Avoid mounting entire `$HOME` directory into the container
- Optimize mounting of SSH and Git configuration files for container
  availability
- Improve user output during installation script

### Fixed

- Redirect installation script error output to **stderr** instead of **stdout**

## [0.1.0] - 2024-04-10

### Added

- Initial version.

[0.1.0]: https://github.com/jnk22/libreelec-git-command/releases/tag/v0.1.0
[0.2.0]: https://github.com/jnk22/libreelec-git-command/compare/v0.1.0...v0.2.0
[0.3.0]: https://github.com/jnk22/libreelec-git-command/compare/v0.2.0...v0.3.0
[unreleased]: https://github.com/jnk22/libreelec-git-command/compare/v0.3.0...HEAD
