#!/bin/bash

function is_semver() {
  local version_string="$1"
  local semver_pattern='^v([0-9]+)\.([0-9]+)\.([0-9]+)$'

  if [[ $version_string =~ $semver_pattern ]]; then
    return 0
  else
    return 1
  fi
}

# Read command line arguments
VERSION=$1
if ! is_semver "$VERSION"; then
	echo "Version $VERSION is not a valid semver version"
	exit 1
fi

# Get build parameters
kernel=`uname -s`
machine=`uname -m`
if [ "$machine" == "x86_64" ]; then
    machine="amd64"
fi
branch=`git rev-parse --abbrev-ref HEAD`
commit=`git rev-parse HEAD`
kernel=`uname -s`
buildtime=`date +%Y-%m-%dT%T%z`

# Prepare linker flags
STRIP_SYMBOLS="-w -s"
STATIC="-extldflags=-static"
LINKER_PKG_PATH=github.com/otoolep/gh-actions-test
LDFLAGS="$STATIC $STRIP_SYMBOLS -X $LINKER_PKG_PATH.Version=$VERSION -X $LINKER_PKG_PATH.Branch=$branch -X $LINKER_PKG_PATH.Commit=$commit -X $LINKER_PKG_PATH.Buildtime=$buildtime"

declare -A compilers
compilers=(
  ["amd64"]="gcc"
)

for arch in "${!compilers[@]}"; do
(
  compiler=${compilers[$arch]}
  echo "Building for $arch using $compiler..."
  CGO_ENABLED=1 GOARCH=$arch CC=$compiler go install -a -tags sqlite_omit_load_extension -ldflags="$LDFLAGS" ./...
)
done

