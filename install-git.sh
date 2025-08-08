#!/usr/bin/env bash
#
# Auto installation script for installing git command to LibreELEC.

set -euo pipefail

readonly REPO_URL=https://github.com/jnk22/libreelec-git-command
readonly BRANCH=main
readonly KODI_DOCKER_ADDON_NAME=service.system.docker
readonly LOCAL_BIN_PATH=.local/bin
readonly GIT_INSTALL_DIR="$HOME/$LOCAL_BIN_PATH"
readonly PROFILE_PATH="$HOME/.profile"
readonly DOCKER_INSTALL_TIMEOUT=120
readonly DOCKER_BIN=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME/bin/docker

#######################################
# Run main function.
# Globals:
#   KODI_DOCKER_ADDON_NAME
#   GIT_INSTALL_DIR
#   PROFILE_PATH
# Arguments:
#   None
#######################################
main() {
  echo "Verifying that system is supported..."
  check_system_supported || failed_abort "This script only supports LibreELEC."

  echo "Verifying that '$KODI_DOCKER_ADDON_NAME' is installed and 'docker' command is available..."
  if ! command -v "$DOCKER_BIN"; then
    echo "Addon not installed. Installing addon now. This may take a while..."
    install_docker_addon
    command -v "$DOCKER_BIN" || failed_abort "Could not install docker addon. Please install manually and try again."
  fi

  echo "Download/Install git wrapper command..."
  install_git_command

  echo "Adding '$GIT_INSTALL_DIR' to PATH..."
  update_profile

  echo "Verifying that 'git' command is now available..."
  [[ ":$PATH:" != *":$GIT_INSTALL_DIR:"* ]] && PATH="$PATH:$GIT_INSTALL_DIR"
  command -v git || failed_abort "Failed to install 'git' command. Please try again."

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

  echo "INSTALLATION FAILED: $error_msg" >&2
  exit 1
}

#######################################
# Verify that current system is supported.
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
# Install docker addon using 'kodi-send'.
# Globals:
#   KODI_DOCKER_ADDON_NAME
#   DOCKER_INSTALL_TIMEOUT
# Arguments:
#   None
# Returns:
#   0 if successful, non-zero otherwise
#######################################
install_docker_addon() {
  kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
  kodi-send --action="Action(\"Left\")" &>/dev/null
  kodi-send --action="Action(\"Select\")" &>/dev/null

  local timeout_counter=0
  until command -v "$DOCKER_BIN" || [ "$timeout_counter" -ge "$DOCKER_INSTALL_TIMEOUT" ]; do
    if [[ "$timeout_counter" -eq 0 ]]; then
      echo "Waiting $DOCKER_INSTALL_TIMEOUT seconds for addon '$KODI_DOCKER_ADDON_NAME' to be installed..."
    fi

    sleep 1
    timeout_counter=$((timeout_counter + 1))
  done
}

#######################################
# Install git command.
# Globals:
#   GIT_INSTALL_DIR
#   REPO_URL
#   BRANCH
# Arguments:
#   None
#######################################
install_git_command() {
  mkdir -p "$GIT_INSTALL_DIR"
  wget -q -O "$GIT_INSTALL_DIR/git" "$REPO_URL/raw/$BRANCH/git"
  chmod +x "$GIT_INSTALL_DIR/git"
}

#######################################
# Update profile source to include binary install path.
# Globals:
#   LOCAL_BIN_PATH
#   PROFILE_PATH
# Arguments:
#   None
#######################################
update_profile() {
  # Do not add '$HOME/.local/bin' if it already exists in any way.
  if ! grep -qE "PATH=.*(\$HOME|~)/${LOCAL_BIN_PATH//./\\.}" "$PROFILE_PATH"; then
    echo -e "\nPATH=\"\$HOME/${LOCAL_BIN_PATH}:\$PATH\"" >>"$PROFILE_PATH"
  fi
}

main
