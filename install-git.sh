#!/usr/bin/env bash
#
# Auto installation script for installing git command to LibreELEC.

set -euo pipefail

readonly REPO_FILE_URL=https://github.com/jnk22/libreelec-git-command/archive/refs/heads/main.zip
readonly REPO_FILE_NAME=libreelec-git-command-main
readonly KODI_DOCKER_ADDON_NAME=service.system.docker
readonly KODI_DOCKER_ADDON_PATH=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME
readonly DOCKER_BIN_PATH=$KODI_DOCKER_ADDON_PATH/bin/docker
readonly PROFILE_PATH=~/.profile
readonly GIT_COMMAND_PATH=~/.git-command
readonly DOCKER_INSTALL_TIMEOUT=120

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
	echo "Verifying that system is supported..."
	check_system_supported

	echo "Verifying that '$KODI_DOCKER_ADDON_NAME' is installed..."
	if ! check_docker_addon_installed; then
		echo "Installing addon now. This may take a while..."
		install_docker_addon
	fi

	echo "Verifying that docker command is available..."
	check_docker_command_available

	echo "Downloading required files..."
	download_required_files

	echo "Building docker image and installing git command..."
	install_docker_image

	echo "Installation finished!"
	echo "Please run 'source ~/.profile' or reconnect once to use the git command."
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
#######################################
check_system_supported() {
	[[ $(grep ^NAME /etc/os-release | cut -d '=' -f 2 | sed "s/\"//g") != "LibreELEC" ]] ||
		failed_abort "This script only supports LibreELEC."

	# if [[ $(grep ^NAME /etc/os-release | cut -d '=' -f 2 | sed "s/\"//g") != "LibreELEC" ]]; then
	# 	failed_abort "This script only supports LibreELEC."
	# fi
}

#######################################
# Verify that docker addon is installed.
# Globals:
#   KODI_DOCKER_ADDON_PATH
# Arguments:
#   None
# Returns:
#   0 if docker addon is installed, 1 otherwise
#######################################
check_docker_addon_installed() {
	[[ -d "$KODI_DOCKER_ADDON_PATH" ]] || return 1
}

#######################################
# Verify that docker command is available.
# Globals:
#   DOCKER_BIN_PATH
# Arguments:
#   None
#######################################
check_docker_command_available() {
	command -v "$DOCKER_BIN_PATH" &>/dev/null ||
		failed_abort "'docker' command is not available. Please re-install docker addon manually."

	# if ! command -v "$DOCKER_BIN_PATH" &>/dev/null; then
	#   failed_abort "'docker' command is not available. Please re-install docker addon manually."
	# fi
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
	kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
	kodi-send --action="Action(\"Left\")" &>/dev/null
	kodi-send --action="Action(\"Select\")" &>/dev/null

	timeout_counter=0
	until check_docker_addon_installed || [ "$timeout_counter" -ge "$DOCKER_INSTALL_TIMEOUT" ]; do
		sleep 1
		timeout_counter=$((timeout_counter + 1))
	done

	check_docker_addon_installed ||
		failed_abort "Could not install addon. Please install manually and try again."
}

#######################################
# Download repository files and prepare for installation.
#   TMP_DIR
#   REPO_FILE_NAME
#   REPO_FILE_URL
# Arguments:
#   None
#######################################
download_required_files() {
	local zip_file_path="$TMP_DIR/$REPO_FILE_NAME.zip"

	wget -q -O "$zip_file_path" "$REPO_FILE_URL"
	unzip -oq "$zip_file_path" -d "$TMP_DIR"
}

#######################################
# Install docker image and make git available as user command.
# Globals:
#   TMP_DIR
#   REPO_FILE_NAME
#   GIT_COMMAND_PATH
#   PROFILE_PATH
# Arguments:
#   None
#######################################
install_docker_image() {
	local repo_dir="$TMP_DIR/$REPO_FILE_NAME"
	local docker_volume_id
	docker_volume_id=$(command "$DOCKER_BIN_PATH" build "$repo_dir" | sed -n -e 's/^.*Successfully built //p')

	sed -e "s/GIT_DOCKER_ID=/GIT_DOCKER_ID=$docker_volume_id/" -- "$repo_dir/git-command-template" >"$GIT_COMMAND_PATH"
	grep -qxF "source $GIT_COMMAND_PATH" "$PROFILE_PATH" || echo "source $GIT_COMMAND_PATH" >>"$PROFILE_PATH"
}

main
