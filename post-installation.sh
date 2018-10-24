#!/bin/bash
# Install this version of firefox as a option for the debian alternatives system under the common alternative names for
# web browsers
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /opt/mozilla/firefox/firefox 0
update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/mozilla/firefox/firefox 0

# Set the new alternative as default
update-alternatives --set gnome-www-browser /opt/mozilla/firefox/firefox
update-alternatives --set x-www-browser /opt/mozilla/firefox/firefox

