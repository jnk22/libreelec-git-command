#!/usr/bin/env bash
#
# Auto installation script for installing git command to LibreELEC.

set -euo pipefail

readonly REPOSITORY=jnk22/libreelec-git-command
readonly BRANCH_NAME=main
readonly KODI_DOCKER_ADDON_NAME=service.system.docker
readonly GIT_INSTALL_PATH=~/.local/bin
readonly PROFILE_PATH=~/.profile
readonly DOCKER_INSTALL_TIMEOUT=120
readonly DOCKER_CONTAINER_NAME=git-command

alias docker='~/.kodi/addons/$KODI_DOCKER_ADDON_NAME/bin/docker'

TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

#######################################
# Run main function.
# Globals:
#   KODI_DOCKER_ADDON_NAME
# Arguments:
#   None
#######################################
main() {
  # TODO: Check if 'git' command is already available.

  echo "Verifying that system is supported..."
  if ! check_system_supported; then
    failed_abort "This script only supports LibreELEC."
  fi

  echo "Verifying that '$KODI_DOCKER_ADDON_NAME' is installed and 'docker' command is available..."
  if ! check_command_available docker; then
    echo "Addon not installed. Installing addon now. This may take a while..."

    install_docker_addon || failed_abort "Could not install docker addon. Please install manually and try again."
  fi

  echo "Downloading installation resources..."
  download_resources

  echo "Building docker container..."
  build_docker_container || failed_abort "Could not build git docker container."

  echo "Install git wrapper command..."
  install_git_command

  # TODO: Only modify profile if necessary.
  echo "Adding $GIT_INSTALL_PATH to PATH..."
  update_profile

  echo "Verifying that 'git' command is now available..."
  check_command_available git || failed_abort "Failed to install 'git' command. Please try again."

  echo "Installation finished!"
  echo "Please run 'source $PROFILE_PATH' or reconnect once to use the 'git' command."
}

#######################################
# Abort installation due to failure.
# Globals:
#   None
# Arguments:
#   error_msg
#######################################
failed_abort() {
  local error_msg=$1

  echo "INSTALLATION FAILED: $error_msg"
  exit 1
}

#######################################
# Verify that current system is supported.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if supported, 1 otherwise
#######################################
check_system_supported() {
  [[ $(grep ^NAME /etc/os-release | cut -d '=' -f 2 | sed "s/\"//g") == "LibreELEC" ]] || return 1
}

#######################################
# Verify that a command is available.
# Globals:
#   None
# Arguments:
#   command_name
# Returns:
#   0 if available, 1 otherwise
#######################################
check_command_available() {
  local command_name=$1
  command -v "$command_name" &>/dev/null || return 1
}

#######################################
# Install docker addon using 'kodi-send'.
# Globals:
#   KODI_DOCKER_ADDON_NAME
#   DOCKER_INSTALL_TIMEOUT
# Arguments:
#   None
#######################################
install_docker_addon() {
  kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
  kodi-send --action="Action(\"Left\")" &>/dev/null
  kodi-send --action="Action(\"Select\")" &>/dev/null

  local timeout_counter=0
  until check_command_available docker || [ "$timeout_counter" -ge "$DOCKER_INSTALL_TIMEOUT" ]; do
    if [[ "$timeout_counter" -eq 0 ]]; then
      echo "Waiting $DOCKER_INSTALL_TIMEOUT seconds for addon '$KODI_DOCKER_ADDON_NAME' to be installed..."
    fi

    sleep 1
    timeout_counter=$((timeout_counter + 1))
  done

  check_command_available docker
}

#######################################
# Download repository files and prepare for installation.
#   REPOSITORY
#   BRANCH_NAME
#   TMP_DIR
# Arguments:
#   None
#######################################
download_resources() {
  local repo_link=https://github.com/$REPOSITORY/raw/$BRANCH_NAME

  wget -q -O "$TMP_DIR/Dockerfile" "$repo_link/Dockerfile"
  wget -q -O "$TMP_DIR/git" "$repo_link/git"
}

#######################################
# Build and install docker container.
# Globals:
#   TMP_DIR
#   REPO_FILE_NAME
#   DOCKER_CONTAINER_NAME
# Arguments:
#   None
# Returns:
#   0 if successful, 1 otherwise
#######################################
build_docker_container() {
  docker build -t "$DOCKER_CONTAINER_NAME" "$TMP_DIR" &>/dev/null || return 1
}

#######################################
# Install git command.
# Globals:
#   TMP_DIR
#   REPO_FILE_NAME#
#   GIT_INSTALL_PATH
# Arguments:
#   None
# Returns:
#   None
#######################################
install_git_command() {
  mkdir -p "$GIT_INSTALL_PATH"
  cp "$TMP_DIR/git" "$GIT_INSTALL_PATH/git"
  chmod +x "$GIT_INSTALL_PATH/git"
}

#######################################
# Update profile source to include binary install path.
# Globals:
#   PROFILE_PATH
# Arguments:
#   None
# Returns:
#   None
#######################################
update_profile() {
  local export_local_bin_path_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
  grep -qxF "$export_local_bin_path_line" "$PROFILE_PATH" &>/dev/null || echo "$export_local_bin_path_line" >>"$PROFILE_PATH"
}

main
