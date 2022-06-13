#!/usr/bin/env bash
# Auto installation script for installing git command to LibreELEC.

REPO_FILE=https://github.com/jnk22/libreelec-git-command/archive/refs/heads/main.zip
KODI_DOCKER_ADDON_NAME=service.system.docker
DOCKER_ADDON_PATH=~/.kodi/addons/$KODI_DOCKER_ADDON_NAME
GIT_COMMAND_SOURCE=~/.git-command

if [ ! -d "$DOCKER_ADDON_PATH" ]; then
  echo "The Docker service addon needs to be installed."
  echo "Please confirm the installation of the Docker addon or install manually."
  echo "Re-run this script after installation."

  # Try to install Docker service addon automatically.
  kodi-send --action="InstallAddon(\"$KODI_DOCKER_ADDON_NAME\")"
  exit 1
fi

# Download repository files and prepare for installation.
mkdir -p /tmp/gitapp && cd "$_" || exit
curl --location --remote-header-name --remote-name $REPO_FILE
unzip libreelec-git-command-main.zip
cd libreelec-git-command || exit

# Run actual install script.
DOCKER_VOLUME_ID=$(docker build . | sed -n -e 's/^.*Successfully built //p')

# Create the git alias function that will be sourced from ~/.profile.
sed -e "s/GIT_DOCKER_ID=/GIT_DOCKER_ID=$DOCKER_VOLUME_ID" -- .git-command >$GIT_COMMAND_SOURCE

# Make git command available by sourcing newly created alias.
grep -qxF 'source ~/.git-command' ~/.profile || echo 'source ~/.git-command' >>~/.profile
source ~/.profile

# Clean up all files after installation.
rm -rf /tmp/gitapp

echo "Installation finished. You can now use the git command!"
