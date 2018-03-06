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
