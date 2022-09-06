#!/bin/bash
# Install this version of firefox as a option for the debian alternatives system under the common alternative names for
# web browsers
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /opt/mozilla/firefox/firefox 0
update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/mozilla/firefox/firefox 0

# Set the new alternative as default
update-alternatives --set gnome-www-browser /opt/mozilla/firefox/firefox
update-alternatives --set x-www-browser /opt/mozilla/firefox/firefox

# Apply default browser configuration for gio mime
if [ -n "$SUDO_USER" ]; then
    SUDO_HOME="$(sudo -s -u "$SUDO_USER" <<< 'echo $HOME')"

    if [ -z "$SUDO_HOME" ]; then
        echo "Unable to determine home directory for installing user."
        echo "Default browser configuration for Gnome (gio) will not be changed."
        exit 0
    fi

    if [ -f "$SUDO_HOME/.local/share/applications/firefox.desktop" ]; then
        echo "A firefox.desktop configuration file was found in '$SUDO_HOME/.local/share/applications'."
        echo "This may shadow the file installed in /usr/share/applications by {{PRODUCT}}."
        echo "If problems occur launching the desired version of Firefox by default,"
        echo "try removing or renaming '$SUDO_HOME/.local/share/applications/firefox.desktop'."
    fi

    echo "Setting Firefox as default browser for Gnome (gio) for $SUDO_USER."
    sudo -u "$SUDO_USER" gio mime x-scheme-handler/http firefox.desktop
    sudo -u "$SUDO_USER" gio mime x-scheme-handler/https firefox.desktop
    echo "If other users want Firefox as the default browser, they may need to configure it manually."
fi