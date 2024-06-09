#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages
# Add COPR repositories
for i in cjuniorfox/hyprland-shell solopasha/hyprland tofik/sway; do
    MAINTAINER="${i%%/*}"
    REPOSITORY="${i##*/}"
    curl --output-dir "/etc/yum.repos.d/" --remote-name \
    "https://copr.fedorainfracloud.org/coprs/${MAINTAINER}/${REPOSITORY}/repo/fedora-${RELEASE}/${MAINTAINER}-${REPOSITORY}-fedora-${RELEASE}.repo"
done

# Install RPM packages
rpm-ostree install \
    adwaita-blue-gtk-theme \
    adwaita-gtk2-theme \
    adwaita-icon-theme \
    adwaita-qt5 \
    azote \
    bash-completion \
    blueman \
    breeze-cursor-theme \
    breeze-gtk \
    breeze-icon-theme \
    chrony \
    dunst \
    firewall-config \
    flatpak \
    fontawesome-6-free-fonts \
    fontawesome-6-brands-fonts \
    git \
    gnome-keyring \
    gnome-packagekit-installer \
    gnome-software \
    gvfs-smb \
    gvfs-nfs \
    htop \
    hyprland \
    kitty \
    liberation-fonts \
    nautilus \
    network-manager-applet \
    pavucontrol \
    pulseaudio-utils \
    rofi-wayland \
    sddm \
    seahorse \
    socat \
    swaybg \
    swayidle \
    swaylock \
    system-config-printer \
    polkit-gnome \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    wlr-randr \
    yaru-{gtk2,gtk3,gtk4,icon,sound}-theme \
    cliphist \
    hyprshot \
    wl-clipboard \
    hyprland-shell-config \
    sway-audio-idle-inhibit

# Remove unnecessary packages
rpm-ostree override remove firefox-langpacks firefox

# Create flatpak-setup.sh
cat << 'EOF' > /usr/bin/flatpak-setup.sh
#!/usr/bin/bash

LOCK_FILE="/var/lib/flatpak-setup-done"

if [ -f "$LOCK_FILE" ]; then
    echo "The Flatpak setup has been previously completed and does not need to be executed again. If you wish to run it again, delete the file '$LOCK_FILE'."
    exit 0
fi

# Function to check internet connectivity
check_internet() {
  while ! curl -s --head https://flathub.org | head -n 1 | grep "200" > /dev/null; do
    echo "Waiting for internet connection..."
    sleep 5
  done
}

check_internet

flatpak remote-delete fedora
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

packages=(
    com.github.tchx84.Flatseal
    org.gnome.Calculator
    org.gnome.Evince
    org.gnome.FileRoller
    org.gnome.FontManager
    org.gnome.Loupe
    org.gnome.TextEditor
    org.mozilla.firefox
    org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
    org.freedesktop.Platform.openh264/x86_64/2.3.1
)

# Install the packages and check for success
for package in "${packages[@]}"; do
    flatpak install --noninteractive flathub "$package"
    if [ $? -eq 0 ]; then
        echo "Package $package installed successfully."
    else
        echo "Error: Failed to install package $package."
        exit 1  # Exit the script if installation fails
    fi
done

# Mark the setup as done
touch "$LOCK_FILE"

# Clean up after successful installation
systemctl disable flatpak-setup.service
EOF

chmod +x /usr/bin/flatpak-setup.sh
chown root:root /usr/bin/flatpak-setup.sh

# Create flatpak-setup.service
cat << EOF > /etc/systemd/system/flatpak-setup.service
[Unit]
Description=First Boot Flatpak Setup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak-setup.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

chown root:root /etc/systemd/system/flatpak-setup.service

# Enable necessary services
systemctl enable flatpak-setup.service

# Set default target to graphical
systemctl set-default graphical.target
