#!/bin/bash

# Download the installer archive from Mozilla distribution server
if [ ! -e firefox-latest.tar.bz2 ]; then
	wget -O firefox-latest.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'
fi

# Make necessary directories
mkdir firefox-vendor
mkdir firefox-vendor/DEBIAN
mkdir -p firefox-vendor/opt/mozilla
mkdir -p firefox-vendor/usr/share/applications

# Extract the installer archive
tar -xjvf firefox-latest.tar.bz2 -C firefox-vendor/opt/mozilla

# Execute the Firefox binary to get the version number
version=$(firefox-vendor/opt/mozilla/firefox/firefox --version | sed 's/.* //')

# Create control file for package
echo "Package: firefox-vendor
Version: $version
Maintainer: $USER
Architecture: amd64
Description: Package of the Firefox web browser as released by Mozilla" > firefox-vendor/DEBIAN/control

# Create desktop entry inside package with appropriate version number
echo "[Desktop Entry]
Version=$version
Name=Mozilla Firefox
Comment=Web Browser
GenericName=Web Browser
Exec=/opt/mozilla/firefox/firefox
Icon=/opt/mozilla/firefox/browser/icons/mozicon128.png
StartupNotify=true
Terminal=false
Type=Application
Categories=Internet;
Keywords=internet;browser;web;mozilla;" > firefox-vendor/usr/share/applications/firefox.desktop

# Build the package
chmod g-s firefox-vendor/DEBIAN
chmod 755 firefox-vendor/DEBIAN
dpkg-deb --build firefox-vendor

# Clean up
rm firefox-latest.tar.bz2
rm -r firefox-vendor
