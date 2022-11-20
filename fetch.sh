#!/usr/bin/env bash

######################################################################
# @author      : Ruan E. Formigoni (ruanformigoni@gmail.com)
# @file        : fetch
######################################################################

set -e

if [ "$2" = "--version" ]; then
  case "$1" in
    "ge") curl -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/GloriousEggroll/wine-ge-custom/releases 2>&1 |
      pcregrep -io "https://.*/download/.*\.tar(\.xz|\.xz)" |
      sort --sort=version |
      tail -n1 |
      pcregrep -io1 "https://.*/download/.*/.*Proton(.*)-x86.*" ;;
    *) curl -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/bottlesdevs/wine/releases 2>&1 |
      pcregrep -io1  "https://.*/download/.*/$1-(.*)-" |
      sed -e '/cx/d' |
      sort --sort=version |
      tail -n1 ;;
  esac

    exit
fi

[ "$1" ] || exit 1

case "$1" in
  "ge") runner="$(curl -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/GloriousEggroll/wine-ge-custom/releases 2>&1 |
    pcregrep -io "https://.*/download/.*\.tar(\.xz|\.xz)" |
    sort --sort=version |
    tail -n1)" ;;
  *) runner="$(curl -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/bottlesdevs/wine/releases 2>&1 |
    pcregrep -io  "https://.*/download/.*/$1-.*\.tar(\.xz|\.gz)" |
    sed -e '/cx/d' |
    sort --sort=version |
    tail -n1)" ;;
esac

echo "runner: $runner"

[ "$runner" ] || exit 1

# Fetch wine
wget -q --show-progress --progress=dot:mega "$runner"

# Extract wine
tar -xf ./*.tar.*

# Create appdir
mkdir -p AppDir

# Copy wine files to appdir
cp -r ./*-x86_64/* AppDir

# Remove tarball and extracted directory
rm ./*.tar.*
rm -rf ./*-x86_64

# // cmd: !./% caffe

#  vim: set expandtab fdm=marker ts=2 sw=2 tw=100 et :
