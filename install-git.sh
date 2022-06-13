#!/usr/bin/env bash
# Auto installation script for installing git command to LibreELEC.

REPO_FILE=https://github.com/jnk22/libreelec-git-command/archive/refs/heads/main.zip
KODI_DOCKER_ADDON_NAME=service.system.docker
KODI_DOCKER_ADDON_PATH=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME
GIT_COMMAND_SOURCE=~/.git-command
TMP_INSTALL_DIR=/tmp/libreelec-git-command

# Verify that Kodi addon is installed.
echo -n "Verify Docker service addon installation..."
if [ ! -d "$KODI_DOCKER_ADDON_PATH" ]; then
  echo
  echo "The Docker service addon needs to be installed."
  echo "Please confirm the installation of the Docker addon or install manually."
  echo "Re-run this script after installation."
  echo "After installing the Docker addon, please reconnect SSH session."

  # Try to install Docker service addon automatically.
  kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
  exit 1
fi
echo " SUCCESS."

# Verify that docker command is available.
echo -n "Verify that docker command is available..."
if ! command -v docker &>/dev/null; then
  echo
  echo "docker command is not available."
  echo "If you have just installed the Docker addon, please reconnect SSH session."
  exit
fi
echo " SUCCESS."

# Download repository files and prepare for installation.
echo -n "Download required files..."
mkdir -p $TMP_INSTALL_DIR && cd $TMP_INSTALL_DIR || exit
wget -q -O libreelec-git-command-main.zip $REPO_FILE
unzip -oq libreelec-git-command-main.zip
cd libreelec-git-command-main || exit
echo " SUCCESS."

# Run actual install script.
echo -n "Install git command..."
DOCKER_VOLUME_ID=$(docker build . | sed -n -e 's/^.*Successfully built //p')

# Create the git alias function that will be sourced from ~/.profile.
sed -e "s/GIT_DOCKER_ID=/GIT_DOCKER_ID=$DOCKER_VOLUME_ID/" -- git-command-template >$GIT_COMMAND_SOURCE

# Make git command available by sourcing newly created alias.
grep -qxF "source $GIT_COMMAND_SOURCE" ~/.profile || echo "source $GIT_COMMAND_SOURCE" >>~/.profile
echo " SUCCESS."

# Clean up all files after installation.
echo -n "Clean up temporary installation files..."
rm -rf $TMP_INSTALL_DIR
echo " SUCCESS."

printf "\nInstallation finished!\n\n"
echo "Please run 'source ~/.profile' or reconnect once to use the git command."
