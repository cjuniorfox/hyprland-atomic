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
    tldr \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    wlr-randr \
    yaru-{gtk2,gtk3,gtk4,icon,sound}-theme \
    cliphist \
    hyprshot \
    waypaper \
    wl-clipboard \
    hyprland-shell-config \
    sway-audio-idle-inhibit

# Remove unnecessary packages
rpm-ostree override remove firefox-langpacks firefox
