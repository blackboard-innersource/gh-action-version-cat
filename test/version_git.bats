#!/usr/bin/env bats

load "version.sh"
load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

TMPDIR=""
LOCAL_DIR=""
REMOTE_DIR=""
CWD=$(pwd)
TEST_TAG="TEST-TAG"

function setup {
  TMPDIR=$(mktemp -d)
  REMOTE_DIR="$TMPDIR/remote"
  LOCAL_DIR="$TMPDIR/local"

  mkdir "$REMOTE_DIR"
  mkdir "$LOCAL_DIR"

  echo "data" > "$REMOTE_DIR/index.txt"

  cd "$REMOTE_DIR" || return 0

  git init
  git config user.email test@example.com
  git config user.name tester
  git add index.txt
  git commit -m test
  git tag "$TEST_TAG"

  cd "$LOCAL_DIR" || return 0

  git init
  git remote add origin "$REMOTE_DIR"

  cd "$CWD" || return 0
}

function teardown {
  if [ -d "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
}

@test "version_tag_exits can validate that git tag exists in remote" {
  cd "$LOCAL_DIR"

  run version_tag_exits "$TEST_TAG"
  assert_success
  assert_output ""
}

@test "version_tag_exits fails to validate when git tag does not exist in remote" {
  cd "$LOCAL_DIR"

  run version_tag_exits "NOT-REAL-TAG"
  assert_failure
  assert_output ""
}
