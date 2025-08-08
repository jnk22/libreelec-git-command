<!-- markdownlint-disable-file MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Changelog file [CHANGELOG.md](CHANGELOG.md)
- Tests for `git` wrapper using [shellspec](https://github.com/shellspec/shellspec)

### Changed

- Use pre-built Docker image [alpine/git](https://hub.docker.com/r/alpine/git)
  instead of building it manually
- Set working directory to `PWD` and mount `PWD:PWD` to improve path handling
  and user output
- Allow overriding docker image and tag via `IMAGE_NAME` and `IMAGE_TAG`
  environment variables
- Do not mount the whole `$HOME` directory into container
- Optimize mounting of SSH and Git configurations to be available within
  container
- Improve user output during installation script

### Fixed

- Allow `git clone` and other subcommands to interact with absolute paths on
  host
- Write error output during installation to **stderr** instead of **stdout**

## 0.1.0 - 2024-04-10

### Added

- Initial version.
