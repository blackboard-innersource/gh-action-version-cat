#!/usr/bin/env bats

load "version.sh"
load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

GITHUB_OUTPUT=""

function setup {
  GITHUB_OUTPUT=$(mktemp)
}

function teardown {
  if [ -f "$GITHUB_OUTPUT" ]; then
    rm "$GITHUB_OUTPUT"
  fi
}

@test "version_read should find version in file" {
  run version_read test/fixtures/version.txt
  assert_success
  assert_output "1.0.0"
}

@test "version_read should find version in multi-line file" {
  run version_read test/fixtures/multi-line-version.txt
  assert_success
  assert_output "1.0.0"
}

@test "version_read should error when file does not exist" {
  run version_read test/fixtures/not-real-path.txt
  assert_failure
  assert_output -p "failed to find version in test/fixtures/not-real-path.txt"
}

@test "version_read should error when file is empty" {
  run version_read test/fixtures/empty-version.txt
  assert_failure
  assert_output "🔥 failed to find version in test/fixtures/empty-version.txt"
}

@test "version_major_minor_patch should split valid version" {
  run version_major_minor_patch "1.2.3"
  assert_success
  assert_output - <<EOF
✅ split version major=1 minor=2 patch=3
EOF

  run cat $GITHUB_OUTPUT
  assert_output - <<EOF
major=1
minor=2
patch=3
EOF
}

@test "version_major_minor_patch should warn if split is not three" {
  run version_major_minor_patch "1.2"
  assert_success
  assert_output "⚠️ could not split version, only version output set"
}

@test "main with version that does not exist" {
  # Mock the git part
  version_tag_exits() { return 1; }
  export -f version_tag_exits

  run main test/fixtures/version.txt test
  assert_success
  assert_output - <<EOF
✅ found test1.0.0 from test/fixtures/version.txt file
✅ git tag test1.0.0 is available
✅ split version major=1 minor=0 patch=0
EOF

  run cat $GITHUB_OUTPUT
  assert_output - <<EOF
version=test1.0.0
major=1
minor=0
patch=0
EOF
}

@test "main with version that does exist" {
  # Mock the git part
  version_tag_exits() { return 0; }
  export -f version_tag_exits

  run main test/fixtures/version.txt test
  assert_failure
  assert_output - <<EOF
✅ found test1.0.0 from test/fixtures/version.txt file
::error file=test/fixtures/version.txt,line=1,col=0::This version already exists, please bump accordingly.
🔥 git tag test1.0.0 already exists!
EOF
}

@test "main fails with bad version file" {
  # Mock the git part
  version_tag_exits() { return 0; }
  export -f version_tag_exits

  run main test/fixtures/not-real-path.txt test
  assert_failure
  assert_output -p "failed to find version in test/fixtures/not-real-path.txt"
}

