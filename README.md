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

## Installing Firefox
1. Make sure that any packages provided by your distribution have been
removed prior to installation.
    ```bash
    sudo apt remove firefox
    #and/or
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
    sudo dpkg --install firefox-vendor.deb
    ```
## Running
From your desktop environment's launcher menu, simply select the Firefox
launcher. To launch from the command-line, use
`/opt/mozilla/firefox/firefox`.

## Uninstalling
Uninstalling is simple and is done through dpkg.
```bash
sudo apt remove firefox-vendor
```

##Conflicts with distribution packages
The name of this package is `firefox-vendor` instead of `firefox` to
avoid conflict with distribution packages. Additionally, this package
installs Firefox into a directory inside of `/opt`, meaning it should
not overwrite and system files for an existing version of Firefox.
However, depending on the distribution package, two visually identical
applicaiton launchers may be created, which is why it is recommended
for most users to remove the version of Firefox from their distribution
prior to installing `firefox-vendor`