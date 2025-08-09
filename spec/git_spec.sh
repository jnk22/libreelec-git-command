#!/usr/bin/env bash

# Set to PWD to ensure that 'git' is the local git wrapper.
export PATH=$PWD:$PATH

run_git_tag_version() {
  local tag="$1"
  IMAGE_TAG=$tag git --version
}

create_and_clone_into_bare_repo() {
  local working_dir="$1"
  cd "$working_dir" || exit 1
  git init --bare -b main repo.git
  git clone repo.git # Clones './repo.git' into './repo'
}

clone_to_relative_path() {
  local working_dir="$1"
  cd "$working_dir" || exit 1
  tar -xf "$OLDPWD/spec/data/test-repo.tar"
  git clone ./test-repo relative-path-repo
}

clone_to_absolute_path() {
  local working_dir="$1"
  cd "$working_dir" || exit 1
  tar -xf "$OLDPWD/spec/data/test-repo.tar"
  git clone test-repo "$(realpath "$working_dir/absolute-path-repo")"
}

init_container() {
  # git
  echo
}

Describe 'git wrapper'
  # Run 'git' once before all tests to ensure that the image is downloaded and
  # Initialized before all actual tests. Otherwise, tests might fail due to
  # cluttered output with image download messages.
  BeforeAll 'init_container'

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
      repo_name=repo
      tmpdir_bare="$(mktemp -d)"
      When call create_and_clone_into_bare_repo "$tmpdir_bare"
      Path RepoPath="$tmpdir_bare/$repo_name"
      The line 1 should include "Initialized empty Git repository in $tmpdir_bare/$repo_name.git/"
      The line 2 should include "Cloning into 'repo'..."
      The line 3 should include "warning: You appear to have cloned an empty repository."
      The line 4 should include "done."
      The path RepoPath should be exist
      The status should be success
      rm -rf "$tmpdir_bare"
    End

    It 'Clones test repository to a relative path in /tmp directory on host'
      repo_name=relative-path-repo
      tmpdir_relative="$(mktemp -d)"
      When call clone_to_relative_path "$tmpdir_relative"
      Path RepoPath="$tmpdir_relative/$repo_name"
      The line 1 should include "Cloning into '$repo_name'..."
      The line 2 should include "done."
      The path RepoPath should be exist
      The status should be success
      rm -rf "$tmpdir_relative"
    End

    It 'Clones test repository to an absolute path in /tmp directory on host'
      repo_name=absolute-path-repo
      tmpdir_absolute="$(mktemp -d)"
      Path RepoPath="$tmpdir_absolute/$repo_name"
      When call clone_to_absolute_path "$tmpdir_absolute"
      The line 1 should include "Cloning into '$tmpdir_absolute/$repo_name'..."
      The line 2 should include "done."
      The path RepoPath should be exist
      The status should be success
      rm -rf "$tmpdir_absolute"
    End
  End
End
