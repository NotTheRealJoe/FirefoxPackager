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
if [ ! -e "${product}_${architecture}.tar.xz" ]; then
	wget -O "${product}_$architecture.tar.xz" "https://download.mozilla.org/?product=${product}&os=${downloadOs}&lang=en-US"
fi

pkgname="${product}_$architecture"

# Make necessary directories
mkdir "$pkgname"
mkdir "$pkgname/DEBIAN"
mkdir -p "$pkgname/opt/mozilla"
mkdir -p "$pkgname/usr/share/applications"
mkdir -p "$pkgname/usr/bin"

# Extract the installer archive
tar -xJvf "${product}_$architecture.tar.xz" -C "$pkgname/opt/mozilla"

# Install the with-profile-manager script
cp "install-files/with-profile-manager" "$pkgname/opt/mozilla/firefox/with-profile-manager"

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
sed -e "s/{{VERSION}}/$version/" -e "s/{{PRODUCT}}/$product/" \
  < install-files/firefox.desktop \
  > "$pkgname/usr/share/applications/firefox.desktop"

# Copy post-installation script into the proper place for the package
#cp post-installation.sh "$pkgname/DEBIAN/postinst"
sed -e "s/{{PRODUCT}}/$product/" \
  < install-files/post-installation.sh \
  > "$pkgname/DEBIAN/postinst"
chmod 755 "$pkgname/DEBIAN/postinst"

# Copy pre-removal script in
cp install-files/pre-remove.sh "$pkgname/DEBIAN/prerm"
chmod 755 "$pkgname/DEBIAN/prerm"

# Build the package
chmod g-s "$pkgname/DEBIAN"
chmod 755 "$pkgname/DEBIAN"
dpkg-deb --build "$pkgname"

# Clean up
rm "firefox-latest_$architecture.tar.xz"
rm -r "$pkgname"

if [ ! -d "output" ]; then
  mkdir output
fi
mv "${pkgname}.deb" "output/"
