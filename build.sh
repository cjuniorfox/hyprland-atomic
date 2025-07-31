#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

echo "Hyprland Build: ${HYPRLAND_BUILD}"
echo "Virtualization: ${VIRTUALIZATION}"
echo "Fedora version: ${RELEASE}"

# Install RPM packages
rpm-ostree install \
    adwaita-gtk2-theme \
    adwaita-icon-theme \
    bash-completion \
    blueman \
    breeze-cursor-theme \
    breeze-gtk \
    breeze-icon-theme \
    chrony \
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
    joystick-support \
    kernel-modules-extra \
    kitty \
    liberation-fonts \
    lxqt-policykit \
    nautilus \
    network-manager-applet \
    pavucontrol \
    pulseaudio-utils \
    rofi-wayland \
    rofimoji \
    sddm \
    seahorse \
    setroubleshoot \
    socat \
    swaybg \
    swaync \
    system-config-printer \
    polkit \
    tldr \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    vulkan-headers vulkan-loader vulkan-tools \
    wlr-randr \
    yaru-{gtk2,gtk3,gtk4,icon,sound}-theme \
    wl-clipboard

if [[ "${VIRTUALIZATION}" == "yes" ]]; then
  echo "Installing virtualization packages"
  rpm-ostree install \
    libvirt-daemon-config-network \
    libvirt-daemon-kvm \
    qemu-kvm \
    guestfs-tools \
    virt-install \
    virt-manager \
    virt-top \
    virt-viewer \
    guestfs-tools \
    python3-tools \
    python3-libguestfs \
    virt-top
fi

# Hyprland from Fedora repository
if [[ "${HYPRLAND_BUILD}" == "fedora" ]]; then
    rpm-ostree install xdg-desktop-portal-hyprland hyprland
fi

# Add COPR repositories
copr="cjuniorfox/hyprland-shell solopasha/hyprland"
for i in ${copr}; do
    MAINTAINER="${i%%/*}"
    REPOSITORY="${i##*/}"
    curl --output "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPOSITORY}.repo" --remote-name \
    "https://copr.fedorainfracloud.org/coprs/${MAINTAINER}/${REPOSITORY}/repo/fedora-${RELEASE}/${MAINTAINER}-${REPOSITORY}-fedora-${RELEASE}.repo"
done

#Install COPR packages from solopasha
rpm-ostree install cliphist eww-git 

# Hyprland from solopasha
if [[ "${HYPRLAND_BUILD}" == "git" ]]; then
    rpm-ostree install hyprlock hypridle hyprland-qtutils hyprpaper hyprshot xdg-desktop-portal-hyprland hyprland-git
elif [[ "${HYPRLAND_BUILD}" == "solopasha" ]]; then
    rpm-ostree install hyprlock hypridle hyprland-qtutils hyprpaper hyprshot xdg-desktop-portal-hyprland hyprland
fi

#Install COPR packages from cjuniorfox/hyprland-shell
rpm-ostree install bibata-cursor-theme hyprland-shell-config install-flatpak-package wol-changer


# Remove the Firefox related packages (will be installed over flatpak)
rpm-ostree override remove firefox-langpacks firefox

#Enable the Installation of the flatpak component org.freedesktop.Platform.openh264 
# after the first boot, this is needed because the flatpak version of Firefox depends # 
# of the openh264 codec, which is not available for offline installation
systemctl enable install-flatpak-package@runtime-org.freedesktop.Platform.openh264-x86_64-2.5.1
