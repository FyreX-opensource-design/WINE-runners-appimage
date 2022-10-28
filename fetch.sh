#!/usr/bin/env bash

######################################################################
# @author      : Ruan E. Formigoni (ruanformigoni@gmail.com)
# @file        : fetch
######################################################################

set -e

if [ "$2" = "--version" ]; then
    curl -H "Accept: application/vnd.github+json" \
        https://api.github.com/repos/bottlesdevs/wine/releases 2>&1 |
        pcregrep -io1  "https://.*/download/.*/$1-(.*)-" |
        sed -e '/cx/d' |
        sort --sort=version |
        tail -n1

    exit
fi

name="$*"

[ "$name" ] || exit 1

runner="$(curl -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/bottlesdevs/wine/releases 2>&1 |
    pcregrep -io  "https://.*/download/.*/$1-.*\.tar(\.xz|\.gz)" |
    sed -e '/cx/d' |
    sort --sort=version |
    tail -n1)"

echo "runner: $runner"

[ "$runner" ] || exit 1

wget -q "$runner"

tar -xf "$name"*.tar.*

cp -r "$name"*-x86_64/* AppDir

rm ./"$name"*.tar.*
rm -rf ./"$name"*-x86_64

# // cmd: !./% caffe

#  vim: set expandtab fdm=marker ts=2 sw=2 tw=100 et :
