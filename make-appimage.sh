#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q oversteer | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/io.github.berarma.Oversteer.svg
export DESKTOP=/usr/share/applications/io.github.berarma.Oversteer.desktop
export DEPLOY_PYTHON=1
export ALWAYS_SOFTWARE=1

# allow relocating locales
sed -i -e 's|localedir =.*|localedir = os.environ.get("TEXTDOMAINDIR", "/usr/share/locale")|' /usr/bin/oversteer

# Deploy dependencies
quick-sharun /usr/bin/oversteer /usr/lib/libgtk-3.so* /usr/lib/libudev.so*

# Add udev rules
mkdir -p ./AppDir/etc/udev/rules.d
cp /usr/lib/udev/rules.d/*wheel-perms* ./AppDir/etc/udev/rules.d

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
