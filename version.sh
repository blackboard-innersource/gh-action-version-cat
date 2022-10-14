#!/usr/bin/env bash

# Send error message to stderr with style
err_msg() {
  echo "🔥 $1" >&2
}

# Read the version from the VERSION file
version_read() {
  local VERSION
  VERSION=$(head -n 1 "$1")
  if [ -z "$VERSION" ]; then
    err_msg "failed to find version in $1"
    return 1
  fi
  echo "$VERSION"
}

# Determine if a tag exists or not
version_tag_exits() {
  git fetch --depth 1 origin "+refs/tags/$1:refs/tags/$1" > /dev/null 2>&1
}

# Given a semver version, split it and output the major, minor and patch
version_major_minor_patch() {
  local PARTS

  # This "splits" the version by the dot character
  # https://github.com/koalaman/shellcheck/wiki/SC2207
  IFS="." read -r -a PARTS <<< "$1"

  if [[ "${#PARTS[@]}" != 3 ]]; then
    echo "⚠️ could not split version, only version output set"
    return 0
  fi

  echo "✅ split version major=${PARTS[0]} minor=${PARTS[1]} patch=${PARTS[2]}"
  echo "major=${PARTS[0]}" >> $GITHUB_OUTPUT
  echo "minor=${PARTS[1]}" >> $GITHUB_OUTPUT
  echo "patch=${PARTS[2]}" >> $GITHUB_OUTPUT
}

main() {
  local RAW_VERSION
  local VERSION

  if ! RAW_VERSION=$(version_read "$1"); then
    return 1
  fi
  VERSION="$2$RAW_VERSION"

  echo "✅ found $VERSION from $1 file"

  if version_tag_exits "$VERSION"; then
    echo "::error file=$1,line=1,col=0::This version already exists, please bump accordingly."
    err_msg "git tag $VERSION already exists!"
    return 1
  fi

  echo "✅ git tag $VERSION is available"
  echo "version=$VERSION" >> $GITHUB_OUTPUT

  version_major_minor_patch "$RAW_VERSION"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if main "$@"; then
    exit 0
  fi
  exit 1
fi