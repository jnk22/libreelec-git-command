#!/usr/bin/env bash
#
# Installation script for 'git' wrapper via Kodi's Docker addon on LibreELEC.

set -euo pipefail

readonly REPO_URL=https://github.com/jnk22/libreelec-git-command
readonly BRANCH=main
readonly GIT_BIN_URL="$REPO_URL/raw/$BRANCH/git"
readonly KODI_DOCKER_ADDON_NAME=service.system.docker
readonly LOCAL_BIN_PATH=.local/bin
readonly PROFILE_PATH_ADDITION="\$HOME/$LOCAL_BIN_PATH"
readonly GIT_INSTALL_DIR="$HOME/$LOCAL_BIN_PATH"
readonly GIT_BIN="$GIT_INSTALL_DIR/git"
readonly PROFILE_PATH="$HOME/.profile"
readonly DOCKER_ADDON_DIR="$HOME/.kodi/addons/$KODI_DOCKER_ADDON_NAME"
readonly DOCKER_BIN="$DOCKER_ADDON_DIR/bin/docker"
readonly DOCKER_INSTALL_TIMEOUT=120

#######################################
# Check whether current system is supported.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if supported, non-zero otherwise
#######################################
check_system_supported() {
  [[ $(grep ^NAME /etc/os-release | cut -d '=' -f 2 | sed "s/\"//g") == "LibreELEC" ]]
}

#######################################
# Check whether docker addon is installed.
# Globals:
#   DOCKER_BIN
# Arguments:
#   None
# Returns:
#   0 if installed, non-zero otherwise
#######################################
check_docker_command_available() {
  command -v "$DOCKER_BIN" &>/dev/null
}

#######################################
# Check whether current PATH already contains git installation directory.
# Globals:
#   GIT_INSTALL_DIR
# Arguments:
#   None
# Returns:
#   0 if present, non-zero otherwise
#######################################
check_path_contains_git_install_dir() {
  [[ ":$PATH:" == *":$GIT_INSTALL_DIR:"* ]]
}

#######################################
# Install docker addon using 'kodi-send'.
# Globals:
#   KODI_DOCKER_ADDON_NAME
# Arguments:
#   None
# Returns:
#   0 if successful, non-zero otherwise
#######################################
install_docker_addon() {
  for action in "InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" "Action(\"Left\")" "Action(\"Select\")"; do
    if ! kodi-send --action="$action" &>/dev/null; then
      return 1
    fi
  done
}

#######################################
# Wait for Docker addon to be available on the system.
# Globals:
#   KODI_DOCKER_ADDON_NAME
#   DOCKER_INSTALL_TIMEOUT
# Arguments:
#   None
# Returns:
#   0 if successful, non-zero otherwise
#######################################
wait_for_docker_addon_install() {
  local timeout_counter=0
  local sleep_interval=1

  echo "Waiting up to $DOCKER_INSTALL_TIMEOUT seconds for addon '$KODI_DOCKER_ADDON_NAME' to be installed..."
  while ! check_docker_command_available && [[ $timeout_counter -lt $DOCKER_INSTALL_TIMEOUT ]]; do
    printf "\rElapsed time: %ds" "$timeout_counter"
    sleep "$sleep_interval"
    timeout_counter=$((timeout_counter + sleep_interval))
  done
  echo

  # At this point we do not know why the while-loop has ended.
  # If the Docker addon is still not installed, we have to fail.
  if ! check_docker_command_available; then
    return 1
  fi
}

#######################################
# Install git wrapper.
# Globals:
#   GIT_BIN
#   GIT_BIN_URL
# Arguments:
#   None
#######################################
install_git_wrapper() {
  mkdir -p "$(dirname "$GIT_BIN")"
  curl -sL -o "$GIT_BIN" "$GIT_BIN_URL"
  chmod +x "$GIT_BIN"
}

#######################################
# Update profile with updated PATH.
# Globals:
#   PROFILE_PATH
#   PROFILE_PATH_ADDITION
# Arguments:
#   None
#######################################
update_profile() {
  printf "\nexport PATH=\"%s:\$PATH\"\n" "$PROFILE_PATH_ADDITION" >>"$PROFILE_PATH"
}

#######################################
# Log error message and exit script.
# Globals:
#   None
# Arguments:
#   error_msg
#######################################
error() {
  local error_msg=$1

  echo "ERROR: $error_msg" >&2
  exit 1
}

#######################################
# Run main function.
# Globals:
#   KODI_DOCKER_ADDON_NAME
#   GIT_INSTALL_DIR
#   GIT_BIN
#   PROFILE_PATH
# Arguments:
#   None
#######################################
main() {
  echo "Verifying that system is supported..."
  check_system_supported || error "This script only supports LibreELEC."

  echo "Verifying that '$KODI_DOCKER_ADDON_NAME' is installed and 'docker' command is available..."
  if ! check_docker_command_available; then
    echo "Addon is not installed. Installing now..."
    install_docker_addon || error "Failed to install Docker addon via 'kodi-send' actions."
    wait_for_docker_addon_install || error "Timeout reached! Addon '$KODI_DOCKER_ADDON_NAME' not installed after $DOCKER_INSTALL_TIMEOUT seconds."
  fi

  echo "Installing 'git' wrapper at '$GIT_BIN'..."
  install_git_wrapper

  echo "Verifying that '$GIT_INSTALL_DIR' is in PATH..."
  if ! check_path_contains_git_install_dir; then
    echo "'$GIT_INSTALL_DIR' is missing from PATH. Updating PATH now..."
    PATH="$GIT_INSTALL_DIR:$PATH"
    update_profile
  fi

  echo "Verifying that 'git' is now available..."
  command -v git &>/dev/null || error "'git' command is not available after installation."

  echo "Installation successful. Please run 'source $PROFILE_PATH' or log out and log back in to use the 'git' command."
}

main
