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
mkdir -p firefox-vendor/usr/bin

# Extract the installer archive
tar -xjvf firefox-latest.tar.bz2 -C firefox-vendor/opt/mozilla

# Create link to executable
ln -s -t firefox-vendor/usr/bin /opt/mozilla/firefox/firefox firefox

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
Icon=/opt/mozilla/firefox/browser/chrome/icons/default/default128.png
StartupNotify=true
Terminal=false
Type=Application
Categories=Internet;
Keywords=internet;browser;web;mozilla;" > firefox-vendor/usr/share/applications/firefox.desktop

# Copy post-installation script into the proper place for the package
cp post-installation.sh firefox-vendor/DEBIAN/postinst
chmod 755 firefox-vendor/DEBIAN/postinst
cp pre-remove.sh firefox-vendor/DEBIAN/prerm
chmod 755 firefox-vendor/DEBIAN/prerm

# Build the package
chmod g-s firefox-vendor/DEBIAN
chmod 755 firefox-vendor/DEBIAN
dpkg-deb --build firefox-vendor

# Clean up
rm firefox-latest.tar.bz2
rm -r firefox-vendor
