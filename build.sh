#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
for i in cjuniorfox/hyprland-shell solopasha/hyprland tofik/sway; do
    MAINTAINER="${i%%/*}"
    REPOSITORY="${i##*/}"
    curl --output-dir "/etc/yum.repos.d/" --remote-name \
    "https://copr.fedorainfracloud.org/coprs/${MAINTAINER}/${REPOSITORY}/repo/fedora-${RELEASE}/${MAINTAINER}-${REPOSITORY}-fedora-${RELEASE}.repo"
done;

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

#ibus-panel removed
#rpm-ostree override remove rofi --install rofi-wayland
rpm-ostree override remove firefox-langpacks firefox

cat << EOF > /usr/bin/flatpak-setup.sh
#!/usr/bin/bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-delete fedora
flatpak install -y \
	com.github.tchx84.Flatseal \
	org.gnome.Calculator \
	org.gnome.Evince \
	org.gnome.FileRoller \
	org.gnome.FontManager \
	org.gnome.Loupe \
	org.gnome.TextEditor \
	org.mozilla.firefox \
	org.freedesktop.Platform.ffmpeg-full/x86_64/22.08 \
	org.freedesktop.Platform.openh264/x86_64/2.3.1

systemctl disable flatpak-setup.service
rm /etc/systemd/system/flatpak-setup.service
rm /usr/bin/flatpak-setup.sh
EOF
chmod +x /usr/bin/flatpak-setup.sh
chown root:root /usr/bin/flatpak-setup.sh

cat << EOF > /etc/systemd/system/flatpak-setup.service
[Unit]
Description=First Boot Flatpak Setup
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak-setup.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
chown root:root /etc/systemd/system/flatpak-setup.service

systemctl enable podman.socket
systemctl enable flatpak-setup.service

systemctl set-default graphical.target 
