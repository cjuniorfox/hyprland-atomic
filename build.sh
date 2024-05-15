#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
for i in cjuniorfox/hyprland-shell solopasha/hyprland Tofik/sway; do
    MAINTAINER="${i%%/*}"
    REPOSITORY="${i##*/}"
    curl --output-dir "/etc/yum.repos.d/" --remote-name \
    "https://copr.fedorainfracloud.org/coprs/${MAINTAINER}/${REPOSITORY}/repo/fedora-${RELEASE}/${MAINTAINER}-${REPOSITORY}-fedora-${RELEASE}.repo"
done;

rpm-ostree refresh-md --force

rpm-ostree install adwaita-blue-gtk-theme \
	adwaita-gtk2-theme \
	adwaita-icon-theme \
	adwaita-qt5 \
	azote \
    bash-completion \
	blueman \
	breeze-cursor-theme \
	breeze-gtk \
	breeze-icon-theme \
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
	ibus-panel \
	kitty \
	liberation-fonts \
	nautilus \
	network-manager-applet \
	pavucontrol \
	pulseaudio-utils \
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
    hyprland-shell-waybar \
	rofi-shutdown-menu \
	wol-changer \
    sway-audio-idle-inhibit

rpm-ostree override remove rofi --install rofi-wayland

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

systemctl enable podman.socket

plymouth-set-default-theme bgrt -R
systemctl set-default graphical.target 
