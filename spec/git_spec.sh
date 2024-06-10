#!/usr/bin/env bash

# TODO: Optimize usage of temporary directories by using /tmp instead.

export CONTAINER_NAME=git-command-test

Describe 'git command'
  setup() { docker build -t "$CONTAINER_NAME" . &>/dev/null; }
  cleanup() { docker image rm "$CONTAINER_NAME" &>/dev/null; }

  BeforeAll 'setup'
  AfterAll 'cleanup'

  check_git_wrapper() { head -n1 "$(command -v git)" && file "$(command -v git)" | cut -d' ' -f2-; }
  run_git_version() { git --version; }
  create_and_clone_into_bare_repo() { cd "$1" && mkdir repo.git && cd repo.git && git init --bare && cd .. && git clone repo.git; }
  clone_to_relative_path() { tar -xf ./spec/data/test-repo.tar -C "$1" && cd "$1" && git clone test-repo relative-path-repo; }
  clone_to_absolute_path() { tar -xf ./spec/data/test-repo.tar -C "$1" && cd "$1" && git clone test-repo "$(realpath "$1"/absolute-path-repo)"; }

  # This test ensures that all test cases actually use the Git command wrapper.
  # Otherwise, we would just use any Git command which might be some other Git
  # command.
  It 'Ensures that Git command is actually the Bash wrapper for Git'
    When call check_git_wrapper
    The output should eq "#!/usr/bin/env bash
Bourne-Again shell script, ASCII text executable"
  End

  # The Git version must match the version that is defined in the Dockerfile.
  It 'Prints installed version information of Git'
    When call run_git_version
    The output should start with "git version 2.43."
  End

  # Related issue: https://github.com/jnk22/libreelec-git-command/issues/2
  It 'Creates a bare repo and clones it into another directory'
    TMPDIR_BARE="$(mktemp -d)"
    trap 'rm -rf -- "$TMPDIR_BARE"' EXIT
    Path RepoPath="$TMPDIR_BARE"
    When call create_and_clone_into_bare_repo "$TMPDIR_BARE"
    The status should be success
    The path RepoPath should be exist
    The output should eq "Initialized empty Git repository in $TMPDIR_BARE/repo.git/"
    The error should eq "Cloning into 'repo'...
warning: You appear to have cloned an empty repository.
done."
  End

  It 'Clones test repository to a relative path in /tmp directory on host'
    TMPDIR_RELATIVE="$(mktemp -d)"
    trap 'rm -rf -- "$TMPDIR_RELATIVE"' EXIT
    Path RepoPath="$TMPDIR_RELATIVE"/relative-path-repo
    When call clone_to_relative_path "$TMPDIR_RELATIVE"
    The status should be success
    The path RepoPath should be exist
    The error should eq "Cloning into 'relative-path-repo'...
done."
  End

  It 'Clones a repository to absolute path in /tmp directory on host'
    TMPDIR_ABSOLUTE="$(mktemp -d)"
    trap 'rm -rf -- "$TMPDIR_ABSOLUTE"' EXIT
    Path RepoPath="$TMPDIR_ABSOLUTE"/absolute-path-repo
    When call clone_to_absolute_path "$TMPDIR_ABSOLUTE"
    The status should be success
    The path RepoPath should be exist
    The error should eq "Cloning into '$TMPDIR_ABSOLUTE/absolute-path-repo'...
done."
  End

End
