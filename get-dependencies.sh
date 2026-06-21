#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	meson             \
	gettext           \
	systemd-libs      \
	python-gobject    \
	python-cairo      \
	python-evdev      \
	python-pyudev     \
	python-pyxdg      \
	python-matplotlib \
	python-scipy

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Building oversteer..."
echo "---------------------------------------------------------------"
git clone https://github.com/berarma/oversteer.git ./oversteer
cd ./oversteer

# Determine to build nightly or stable
if [ "${DEVEL_RELEASE-}" = 1 ]; then
	git rev-parse --short HEAD > ~/version
else
	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version
fi

meson setup build --prefix=/usr
ninja -C build
ninja -C build install
