#!/usr/bin/env bash

######################################################################
# @author      : Ruan E. Formigoni (ruanformigoni@gmail.com)
# @file        : patch.sh
# @created     : Saturday Jan 21, 2023 21:29:49 -03
######################################################################

set -e

# Unpack Appimage
# shellcheck disable=2211
[ -d ./out ] ||
  { ./"$1" --appimage-extract && mv squashfs-root out; }

# Symlink setup
# shellcheck disable=2016
sed -i -e 's|# CI_PLACEHOLDER|# Setup symlinks\n( LOC=$(readlink -f "$APPDIR") ; cd /tmp ; ln -sf "$LOC"/{i386-linux-gnu,lib,ld-linux.so.2} . )|g' ./out/wrapper

# Unpack wine
mkdir -p wine
# [ -d "$(pwd)/wine" ] || tar -xf "$1" --directory="$(pwd)/wine"
tar -xvf ./*.tar.* -C "$(pwd)/wine" --strip-components=1

# Remove old dirs and symlinks
rm -rfv ./usr /tmp/i386-linux-gnu /tmp/lib /tmp/ld-linux.so.2

# Copy i386 libs
cp -rv ./out/lib/i386-linux-gnu/ /tmp
cp -rv ./out/runtime/compat/lib/i386-linux-gnu/* /tmp/i386-linux-gnu

cp -rv ./out/usr/lib /tmp
cp -rv ./out/runtime/compat/usr/lib/i386-linux-gnu/* /tmp/lib

# Copy preloader
cp -rv ./out/runtime/compat/lib/i386-linux-gnu/ld-linux.so.2 /tmp/ld-linux.so.2

# Patch wine
patchelf --set-interpreter /tmp/ld-linux.so.2 ./wine/bin/wine

# Patch ld-linux.so.2
sed -i -e 's|/usr/lib/i386-linux-gnu/|/tmp/lib/i386-linux-gnu/|g' /tmp/ld-linux.so.2
sed -i -e 's|/lib/i386-linux-gnu/|/tmp/i386-linux-gnu/|g' /tmp/ld-linux.so.2

# Now disable loading from the system paths stored in /etc
sed -i -e 's|/etc/ld.so.cache|/xxx/ld.so.cache|g' /tmp/ld-linux.so.2

# Change search path of glibc
sed -i -e 's|/usr/lib/i386-linux-gnu/|/tmp/lib/i386-linux-gnu/|g' /tmp/i386-linux-gnu/libc.so.6

# Create symlinks
mkdir -p ./usr/tmp
mv /tmp/lib /tmp/i386-linux-gnu /tmp/ld-linux.so.2 ./usr/tmp/
( LOC=$(readlink -f ./usr/tmp/) ; cd /tmp ; ln -s "$LOC"/* . )

# Move wine inside the build dir
cp -r ./wine/* ./usr/tmp/ && rm -rf ./wine

# Remove need to use LD_LIBRARY_PATH
# shellcheck disable=2016
find usr/tmp/lib/wine/i386-unix/*.so* -exec patchelf --set-rpath '$ORIGIN:$ORIGIN/../:$ORIGIN/../../tmp/i386-linux-gnu:$ORIGIN/../../tmp/lib/i386-linux-gnu' {} \; || true
# shellcheck disable=2016
find usr/tmp/lib/*.so* -exec patchelf --set-rpath '$ORIGIN:$ORIGIN/../tmp/i386-linux-gnu:$ORIGIN/../tmp/lib/i386-linux-gnu' {} \; || true
# shellcheck disable=2016
find usr/tmp/i386-linux-gnu/*so* -exec patchelf --set-rpath '$ORIGIN' {} \; || true
# shellcheck disable=2016
find usr/tmp/lib/i386-linux-gnu/*so* -exec patchelf --set-rpath '$ORIGIN:$ORIGIN/..' {} \; || true

# Move wine inside the install prefix
cp -r ./usr/tmp/* out

# Show strings in modified preloader
strings /tmp/ld-linux.so.2 | grep lib/

# Re-Package
[ -d appimagetool ] && rm -rf appimagetool

wget -q --show-progress --progress=dot:mega -O appimagetool \
  https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage

chmod +x appimagetool

./appimagetool --appimage-extract

rm appimagetool

mv squashfs-root appimagetool

ARCH=x86_64 ./appimagetool/AppRun out

# LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/tmp/i386-linux-gnu:/tmp/lib/i386-linux-gnu"
#
# for i in $(grep -lrin ld-linux out/bin/); do patchelf --set-interpreter /tmp/compat/lib/ld-linux.so.2 "$i"; done
#
# LD_TRACE_LOADED_OBJECTS=1 ./out/bin/wine --version
#
# patchelf --set-interpreter /tmp/compat/lib/i386-linux-gnu/ld-linux.so.2 wine/bin/wine
#
# patchelf --set-interpreter /tmp/compat/lib/i386-linux-gnu/ld-linux.so.2 --set-rpath /tmp/compat/lib/i386-linux-gnu/ wine/bin/wine
#
# export LD_LIBRARY_PATH=/tmp/compat/lib/:/tmp/compat/lib/i386-linux-gnu/:/tmp/compat/lib64:/tmp/compat/lib/x86_64-linux-gnu/
#
# LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/tmp/compat/lib/:/tmp/compat/lib/i386-linux-gnu" ./wine/bin/wine winecfg
#
# LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/tmp/compat/lib/:/tmp/compat/lib/i386-linux-gnu" strace ./wine/bin/wine winecfg 2>&1 | grep -E '"/lib/i386-linux-gnu' | cut -d '"' -f 2
#
# mount -o remount,size=4G,noatime /tmp
#
# /lib/i386-linux-gnu/
# /usr/lib/i386-linux-gnu/
# /lib/
# /usr/lib/
# /lib/i386-linux-gnu/
# /usr/lib/i386-linux-gnu/
# /lib/
# /usr/lib/
# lib/i386-linux-gnu
# /lib/ld-linux.so.2
