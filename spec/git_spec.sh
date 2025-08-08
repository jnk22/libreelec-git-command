#!/usr/bin/env bash

# Set to PWD to ensure that 'git' is the local git wrapper.
export PATH=$PWD:$PATH

get_git_command_filetype() {
  file -b "$(command -v git)"
}

run_git_tag_version() {
  local tag="$1"
  IMAGE_TAG=$tag git --version
}

create_and_clone_into_bare_repo() {
  local directory="$1"
  cd "$directory" || exit 1
  mkdir repo.git
  cd repo.git || exit 1
  git init --bare -b main
  cd .. || exit 1
  git clone repo.git
}

clone_to_relative_path() {
  tar -xf ./spec/data/test-repo.tar -C "$1"
  cd "$1" || exit 1
  git clone test-repo relative-path-repo
}

clone_to_absolute_path() {
  tar -xf ./spec/data/test-repo.tar -C "$1"
  cd "$1" || exit 1
  git clone test-repo "$(realpath "$1"/absolute-path-repo)"
}

Describe 'git wrapper check'
  It 'Ensures that git command is the local wrapper'
    When call command -v git
    The output should eq "$PWD/git"
    The status should be success
  End

  It 'Ensures that Git command is a Bash script'
    When call file -b "$(command -v git)"
    The output should eq "Bourne-Again shell script, ASCII text executable"
    The status should be success
  End

End

Describe 'git version and help'
  It 'Prints version information'
    When call git --version
    The output should match pattern "git version *.*.*"
    The status should be success
  End

  It 'Prints help output'
    When call git --help
    The line 1 should include "usage: git"
    The status should be success
  End
End

Describe 'git version can be modified via image tag'
  It 'Prints installed version information of Git'
    When call run_git_tag_version 2.49.1
    The output should include "git version 2.49.1"
    The status should be success
  End

  It 'Allows setting specific image tag'
    When call run_git_tag_version 2.49.0
    The output should include "git version 2.49.0"
    The status should be success
  End
End

Describe 'git clone'
  # Related issue: https://github.com/jnk22/libreelec-git-command/issues/2
  It 'Creates a bare repo and clones it into another directory'
    tmpdir_bare="$(mktemp -d)"
    trap 'rm -rf -- "$tmpdir_bare"' EXIT
    Path RepoPath="$tmpdir_bare"
    When call create_and_clone_into_bare_repo "$tmpdir_bare"
    The status should be success
    The path RepoPath should be exist
    The line 1 should include "Initialized empty Git repository in $tmpdir_bare/repo.git/"
    The line 2 should include "Cloning into 'repo'..."
    The line 3 should include "warning: You appear to have cloned an empty repository."
    The line 4 should include "done."
  End

  It 'Clones test repository to a relative path in /tmp directory on host'
    tmpdir_relative="$(mktemp -d)"
    trap 'rm -rf -- "$tmpdir_relative"' EXIT
    Path RepoPath="$tmpdir_relative"/relative-path-repo
    When call clone_to_relative_path "$tmpdir_relative"
    The line 1 should include "Cloning into 'relative-path-repo'..."
    The line 2 should include "done."
    The path RepoPath should be exist
    The status should be success
  End

  It 'Clones test repository to an absolute path in /tmp directory on host'
    tmpdir_absolute="$(mktemp -d)"
    trap 'rm -rf -- "$tmpdir_absolute"' EXIT
    Path RepoPath="$tmpdir_absolute"/absolute-path-repo
    When call clone_to_absolute_path "$tmpdir_absolute"
    The line 1 should include "Cloning into '$tmpdir_absolute/absolute-path-repo'..."
    The line 2 should include "done."
    The path RepoPath should be exist
    The status should be success
  End
End
