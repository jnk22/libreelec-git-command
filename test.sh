#!/usr/bin/env bash

readonly XX=$1

check_docker_addon_installed() {
	[[ -d "$XX" ]] && return || return 1
}

if check_docker_addon_installed; then
	echo "Installed!"
else
	echo "Not :()"
fi
