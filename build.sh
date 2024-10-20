#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

echo "Hyprland Build: ${HYPRLAND_BUILD}"
echo "Virtualization: ${VIRTUALIZATION}"
echo "Fedora version: ${RELEASE}"

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
    gnome-disk-utility \
    gnome-keyring \
    gnome-packagekit-installer \
    gnome-software \
    gvfs-smb \
    gvfs-nfs \
    htop \
    kitty \
    liberation-fonts \
    nautilus \
    network-manager-applet \
    pavucontrol \
    pulseaudio-utils \
    rofi-wayland \
    rofimoji \
    sddm \
    seahorse \
    socat \
    swaybg \
    system-config-printer \
    polkit-gnome \
    tldr \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    xdg-desktop-portal-hyprland \
    vulkan-headers vulkan-loader vulkan-tools \
    wlr-randr \
    yaru-{gtk2,gtk3,gtk4,icon,sound}-theme \
    wl-clipboard

if [[ "${VIRTUALIZATION}" == "yes" ]]; then
  rpm-ostree install \
    virt-install \
    libvirt-daemon-config-network \
    libvirt-daemon-kvm \
    qemu-kvm \
    virt-manager \
    virt-viewer \
    guestfs-tools \
    python3-tools \
    python3-libguestfs \
    virt-top
fi

# Hyprland from Fedora repository
if [[ "${HYPRLAND_BUILD}" == "fedora" ]]; then
    rpm-ostree install hyprland
fi

# Add COPR repositories
for i in cjuniorfox/hyprland-shell solopasha/hyprland tofik/sway; do
    MAINTAINER="${i%%/*}"
    REPOSITORY="${i##*/}"
    curl --output "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPOSITORY}.repo" --remote-name \
    "https://copr.fedorainfracloud.org/coprs/${MAINTAINER}/${REPOSITORY}/repo/fedora-${RELEASE}/${MAINTAINER}-${REPOSITORY}-fedora-${RELEASE}.repo"
done

#Install COPR packages from solopasha
rpm-ostree install cliphist eww-git hypridle hyprlock hyprshot waypaper 

# Hyprland from solopasha
if [[ "${HYPRLAND_BUILD}" == "git" ]]; then
    rpm-ostree install hyprland-git
elif [[ "${HYPRLAND_BUILD}" == "solopasha" ]]; then
    rpm-ostree install hyprland
fi

#Install COPR packages from cjuniorfox/hyprland-shell
rpm-ostree install hyprland-shell-config wol-changer  

#Install COPR packages from tofik/sway
rpm-ostree install sway-audio-idle-inhibit

# Remove the Firefox related packages (will be installed over flatpak)
rpm-ostree override remove firefox-langpacks firefox
