#!/bin/bash

if [ -n "$1" ]; then
  archString="$1"
else
  archString=$(uname -m)
fi

if [ -n "$2" ]; then
  product="$2"
else
  product='firefox-latest'
fi

if [ -z "$archString" ]; then
  echo "Unable to determine architecture. Please specify it as the first argument."
fi

# Set architecture
case "$archString" in
	"amd64"|"x86_64"|"x86-64"|"x64"|"64")
		architecture="amd64"
		downloadOs="linux64"
		;;
	"i386"|"i686"|"x86"|"32")
		architecture="i386"
		downloadOs="linux"
		;;
  *)
    echo "Unable to recognize architecture $archString"
    exit 1
esac

# Download the installer archive from Mozilla distribution server
if [ ! -e "${product}_${architecture}.tar.bz2" ]; then
	wget -O "${product}_$architecture.tar.bz2" "https://download.mozilla.org/?product=${product}&os=${downloadOs}&lang=en-US"
fi

pkgname="${product}_$architecture"

# Make necessary directories
mkdir "$pkgname"
mkdir "$pkgname/DEBIAN"
mkdir -p "$pkgname/opt/mozilla"
mkdir -p "$pkgname/usr/share/applications"
mkdir -p "$pkgname/usr/bin"

# Extract the installer archive
tar -xjvf "${product}_$architecture.tar.bz2" -C "$pkgname/opt/mozilla"

# Create link to executable
ln -s -t "$pkgname/usr/bin" "/opt/mozilla/firefox/firefox" firefox

# Get the version from application.ini
version=$(grep -E "^Version" < "$pkgname/opt/mozilla/firefox/application.ini" | sed 's/.*=//')

if [ -z "$version" ]; then
  echo "Unable to determine version - not continuing."
  exit 1
fi

# Create control file for package
echo "Package: ${product}
Version: ${version}
Maintainer: ${USER}
Architecture: ${architecture}
Description: Package of the Firefox web browser as released by Mozilla" > "$pkgname/DEBIAN/control"

# Create desktop entry inside package with appropriate version number
echo "[Desktop Entry]
Version=$version
Name=$product
Comment=Web Browser
GenericName=Web Browser
Exec=/opt/mozilla/firefox/firefox
Icon=/opt/mozilla/firefox/browser/chrome/icons/default/default128.png
StartupNotify=true
Terminal=false
Type=Application
Categories=Internet;
Keywords=internet;browser;web;mozilla;" > "$pkgname/usr/share/applications/firefox.desktop"

# Copy post-installation script into the proper place for the package
cp post-installation.sh "$pkgname/DEBIAN/postinst"
chmod 755 "$pkgname/DEBIAN/postinst"
cp pre-remove.sh "$pkgname/DEBIAN/prerm"
chmod 755 "$pkgname/DEBIAN/prerm"

# Build the package
chmod g-s "$pkgname/DEBIAN"
chmod 755 "$pkgname/DEBIAN"
dpkg-deb --build "$pkgname"

# Clean up
rm "firefox-latest_$architecture.tar.bz2"
rm -r "$pkgname"
