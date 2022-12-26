#!/usr/bin/env bash
#
# Auto installation script for installing git command to LibreELEC.set -euo pipefail
set -euxo pipefail

readonly REPO_FILE_URL=https://github.com/jnk22/libreelec-git-command/archive/refs/heads/main.zip
readonly REPO_FILE_NAME=libreelec-git-command-main
readonly KODI_DOCKER_ADDON_NAME=service.system.docker
readonly KODI_DOCKER_ADDON_PATH=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME
readonly DOCKER_BIN_PATH=/storage/.kodi/addons/service.system.docker/bin/docker
readonly GIT_COMMAND_SOURCE=~/.git-command
readonly TMP_INSTALL_DIR=/tmp/libreelec-git-command
readonly DOCKER_INSTALL_TIMEOUT=30

#######################################
# Abort installation due to failure.
# Globals:
#   None
# Arguments:
#   err_msg
#######################################
failed_abort() {
	local error_msg=$1

	echo "INSTALLATION FAILED: $error_msg"
	exit 1
}

#######################################
# Verify that current system is supported (i.e. 'LibreELEC').
# Globals:
#   None
# Arguments:
#   None
#######################################
check_system_supported() {
	echo "Verify that system is supported..."

	if [[ $(grep ^NAME /etc/os-release | cut -d '=' -f 2 | sed "s/\"//g") != "LibreELEC" ]]; then
		failed_abort "This script only supports LibreELEC."
	fi
}

#######################################
# Verify that docker addon is installed.
# Globals:
#   KODI_DOCKER_ADDON_PATH
# Arguments:
#   None
#######################################
check_docker_addon_installed() {
	echo "Verify docker service addon installation..."

	if [ ! -d "$KODI_DOCKER_ADDON_PATH" ]; then
		fail
		return
	fi
}

#######################################
# Install docker addon using 'kodi-send'.
# Globals:
#   KODI_DOCKER_ADDON_NAME
#   DOCKER_BIN_PATH
#   DOCKER_INSTALL_TIMEOUT
# Arguments:
#   None
#######################################
install_docker_addon() {
	echo "Installing docker service addon now..."

	kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
	kodi-send --action "Action(\"Left\")" &>/dev/null
	kodi-send --action "Action(\"Select\")" &>/dev/null

	timeout_counter=0
	until [ -f "$DOCKER_BIN_PATH" ] || [ "$timeout_counter" -ge "$DOCKER_INSTALL_TIMEOUT" ]; do
		sleep 1
		timeout_counter=$((timeout_counter + 1))
	done

	if [ ! -f "$DOCKER_BIN_PATH" ]; then
		failed_abort "docker addon installation failed. Please manually install the docker addon."
	fi
}

#######################################
# Verify that docker command is available.
# Globals:
#   None
# Arguments:
#   None
#######################################
check_docker_command_available() {
	echo "Verify that docker command is available..."

	if ! command -v "$(DOCKER_BIN_PATH)" &>/dev/null; then
		failed_abort "docker command is not available. Please re-install docker addon manually."
	fi
}

#######################################
# Download repository files and prepare for installation.
#   TMP_INSTALL_DIR
#   REPO_FILE_URL
# Arguments:
#   None
#######################################
download_required_files() {
	echo "Download required files..."

	mkdir -p "$TMP_INSTALL_DIR"
	cd "$TMP_INSTALL_DIR" || failed_abort "Could not cd into $TMP_INSTALL_DIR."
	wget -q -O REPO_FILE_NAME.zip "$REPO_FILE_URL"
	unzip -oq REPO_FILE_NAME.zip
	cd REPO_FILE_NAME || failed_abort "Could not cd into $REPO_FILE_NAME."
}

#######################################
# Install docker image and make available as user command.
# Globals:
#   DOCKER_VOLUME_ID
#   GIT_COMMAND_SOURCE
# Arguments:
#   None
#######################################
install_docker_image() {
	echo "Install git command..."
	DOCKER_VOLUME_ID=$(docker build . | sed -e 's/^.*Successfully built //p')
	sed -e "s/GIT_DOCKER_ID=/GIT_DOCKER_ID=$DOCKER_VOLUME_ID/" -- git-command-template >"$GIT_COMMAND_SOURCE"
	grep -qxF "source $GIT_COMMAND_SOURCE" ~/.profile || echo "source $GIT_COMMAND_SOURCE" >>~/.profile
}

#######################################
# Clean up all files after installation.
# Globals:
#   TMP_INSTALL_DIR
# Arguments:
#   None
#######################################
post_cleanup_files() {
	echo "Clean up temporary installation files..."
	rm -rf "$TMP_INSTALL_DIR"
}

# Run pre-checks that are required for building docker images.
check_system_supported
check_docker_addon_installed || install_docker_addon
check_docker_command_available

# Install actual docker image.
download_required_files
install_docker_image
post_cleanup_files

echo "Installation finished! Please run 'source ~/.profile' or reconnect once to use the git command."
