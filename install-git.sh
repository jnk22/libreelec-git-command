#!/usr/bin/env bash
# Auto installation script for installing git command to LibreELEC.

REPO_FILE=https://github.com/jnk22/libreelec-git-command/archive/refs/heads/main.zip
KODI_DOCKER_ADDON_NAME=service.system.docker
KODI_DOCKER_ADDON_PATH=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME
GIT_COMMAND_SOURCE=~/git-command-template
TMP_INSTALL_DIR=/tmp/libreelec-git-command

if [ ! -d "$KODI_DOCKER_ADDON_PATH" ]; then
  echo "The Docker service addon needs to be installed."
  echo "Please confirm the installation of the Docker addon or install manually."
  echo "Re-run this script after installation."

  # Try to install Docker service addon automatically.
  kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")" &>/dev/null
  exit 1
fi

# Download repository files and prepare for installation.
mkdir -p $TMP_INSTALL_DIR && cd $TMP_INSTALL_DIR || exit
wget -O libreelec-git-command-main.zip $REPO_FILE
unzip -oq libreelec-git-command-main.zip
cd libreelec-git-command-main || exit

# Run actual install script.
# TODO: Check whether docker command is available
DOCKER_VOLUME_ID=$(docker build . | sed -n -e 's/^.*Successfully built //p')

# Create the git alias function that will be sourced from ~/.profile.
sed -e "s/GIT_DOCKER_ID=/GIT_DOCKER_ID=$DOCKER_VOLUME_ID/" -- git-command-template >$GIT_COMMAND_SOURCE

# Make git command available by sourcing newly created alias.
grep -qxF "source $GIT_COMMAND_SOURCE" ~/.profile || echo "source $GIT_COMMAND_SOURCE" >>~/.profile
source ~/.profile

# Clean up all files after installation.
rm -rf $TMP_INSTALL_DIR

echo "Installation finished."
echo "Please run 'source ~/.profile' or log off and on again once to use the git command!"
