#!/usr/bin/env bash
#
# Auto installation script for installing git command to LibreELEC.

readonly REPO_FILE=https://github.com/jnk22/libreelec-git-command/archive/refs/heads/main.zip
readonly KODI_DOCKER_ADDON_NAME=service.system.docker
readonly KODI_DOCKER_ADDON_PATH=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME
readonly DOCKER_BIN_PATH=/storage/.kodi/addons/service.system.docker/bin/docker
readonly GIT_COMMAND_SOURCE=~/.git-command
readonly TMP_INSTALL_DIR=/tmp/libreelec-git-command
readonly DOCKER_INSTALL_TIMEOUT=30

#######################################
# Install docker addon using 'kodi-send'.
# Globals:
#   KODI_DOCKER_ADDON_NAME
# Arguments:
#   None
#######################################
install_docker_addon() {
	kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
	kodi-send --action "Action(\"Left\")" &>/dev/null
	kodi-send --action "Action(\"Select\")" &>/dev/null

	timeout_counter=0
	until [ -f "$DOCKER_BIN_PATH" ] || [ "$timeout_counter" -ge "$DOCKER_INSTALL_TIMEOUT" ]; do
		sleep 1
		timeout_counter=$((timeout_counter + 1))
	done

	if [ ! -f "$DOCKER_BIN_PATH" ]; then
		echo " FAILED."
		exit 1
	fi
	echo " SUCCESS."
}

#######################################
# Verify that docker addon is installed.
# Globals:
#   KODI_DOCKER_ADDON_PATH
# Arguments:
#   None
#######################################
check_docker_addon_installed() {
	echo -n "Verify Docker service addon installation..."
	if [ ! -d "$KODI_DOCKER_ADDON_PATH" ]; then
		echo -e "\nDocker is not yet installed. Installing Docker service addon now..."
		install_docker_addon
	fi
}

#######################################
# Verify that current system is 'LibreELEC'.
# Globals:
#   KODI_DOCKER_ADDON_NAME
# Arguments:
#   None
#######################################
check_system_supported() {
	# Verify that system is supported.
	if [[ $(grep ^NAME /etc/os-release | cut -d '=' -f 2 | sed "s/\"//g") != "LibreELEC" ]]; then
		echo "This script only supports LibreELEC."
		exit 1
	fi
}

#######################################
# Download repository files and prepare for installation.
# Globals:
#   KODI_DOCKER_ADDON_NAME
# Arguments:
#   None
#######################################
download_required_files() {
	echo -n "Download required files..."
	mkdir -p "$TMP_INSTALL_DIR" && cd "$TMP_INSTALL_DIR" || exit 1
	wget -q -O libreelec-git-command-main.zip "$REPO_FILE"
	unzip -oq libreelec-git-command-main.zip
	cd libreelec-git-command-main || exit 1
	echo " SUCCESS."
}

#######################################
# Verify that docker command is available.
# Globals:
#   KODI_DOCKER_ADDON_NAME
# Arguments:
#   None
#######################################
check_docker_command_available() {
	echo -n "Verify that docker command is available..."
	if ! command -v "$(DOCKER_BIN_PATH)" &>/dev/null; then
		echo " FAILED."
		exit 1
	fi
	echo " SUCCESS."
}

check_system_supported
check_docker_addon_installed
check_docker_command_available

download_required_files

# Run actual install script.
echo -n "Install git command..."
DOCKER_VOLUME_ID=$(docker build . | sed -n -e 's/^.*Successfully built //p')

# Create the git alias function that will be sourced from ~/.profile.
sed -e "s/GIT_DOCKER_ID=/GIT_DOCKER_ID=$DOCKER_VOLUME_ID/" -- git-command-template >"$GIT_COMMAND_SOURCE"

# Make git command available by sourcing newly created alias.
grep -qxF "source $GIT_COMMAND_SOURCE" ~/.profile || echo "source $GIT_COMMAND_SOURCE" >>~/.profile
echo " SUCCESS."

# Clean up all files after installation.
echo -n "Clean up temporary installation files..."
rm -rf "$TMP_INSTALL_DIR"
echo " SUCCESS."

echo -e "\nInstallation finished!\n"
echo "Please run 'source ~/.profile' or reconnect once to use the git command."
