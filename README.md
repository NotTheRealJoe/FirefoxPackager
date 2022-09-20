# FirefoxPackager
Automatically generate a Debian package for Mozilla Firefox based upon
the current release on Mozilla's website.

This repository is a script to *generate* packages, it does not have the
packages themselves.

The generated package will generally be ahead of distribution packages
in version, but does not use the libraries or other components installed
on the system, so will take up more disk space when installed.

Make sure to uninstall any Firefox package provided by your distribution
before installing the generated package.

## Requirements
 - An x86 or amd64 architecture system. Specifically, the value reported by
 `uname -m` must be one of the following:
    ```
    "amd64" "x86_64" "x86-64" "x64" "64" "i386" "i686" "x86" "32"
    ```
- Debian system with `dpkg` in PATH.

## Installing Firefox
1. Make sure that any packages provided by your distribution have been
removed prior to installation (see end of this document for further info on
potential conflicts with distribution packages).
    ```bash
    sudo apt remove firefox
    # and/or
    sudo apt remove firefox-esr
    ```
    Advanced users, see my notes about conflict with distribution packages
1. Clone this repository and enter it
    ```bash
    git clone https://github.com/NotTheRealJoe/FirefoxPackager.git
    cd FirefoxPackager
    ```
1. Run the script
    ```bash
    ./build-package.sh
    ```
    The script will take a few moments to download the package from
    Mozilla's servers, and compile it to a deb package
1. Install the generated package
    ```bash
    sudo dpkg --install output/firefox-latest_<arch>.deb
    ```
## Running
From your desktop environment's launcher menu, simply select the Firefox
launcher. To launch from the command-line, use
`/opt/mozilla/firefox/firefox`.

## Default browser
By default, the package's post-installation script will attempt to install this
version of Firefox as the default browser in 3 ways:
1. In `/etc/alternatives` for `x-www-browser` (system-wide)
1. In `/etc/alternatives` for `gnome-www-browser` (system-wide)
1. Using `gio`, for the user specified in `$SUDO_USER`.

The first two may be changed by using
`update-alternatives --config x-www-browser` and
`update-alternatives --config gnome-www-browser` respectively.
An alternative `/opt/mozilla/firefox/with-profile-manager` is also added, which
will set the default browser to Firefox with the `--ProfileManager` flag. This
will show the Profile Manager to allow the user to choose the desired profile
before the actual browser launches.

The `gio` default browser is set for the user in `$SUDO_USER`, if set. This
means it *will* be set if the browser is installed by someone calling
`sudo dpkg...` but *would not* be set if `dpkg` is called directly by the root
user. The package also *will not* set the `gio` default browser for any other
users on the system. If those users desire this copy of Firefox as the `gio`
default browser, they can set it with:
```
gio mime x-scheme-handler/http firefox.desktop
gio mime x-scheme-handler/https firefox.desktop
```

## Uninstalling
Uninstalling is simple and is done through dpkg.
```bash
sudo apt remove firefox-latest
```

## Conflicts with distribution packages
The name of this package is `firefox-latest` instead of `firefox` to
avoid conflict with distribution packages. Additionally, this package
installs Firefox into a directory inside of `/opt`, meaning it should
not overwrite and system files for an existing version of Firefox.
However, depending on the distribution package, two visually identical
applicaiton launchers may be created, which is why it is recommended
for most users to remove the version of Firefox from their distribution
prior to installing `firefox-latest`.