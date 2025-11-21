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
    desktop-backgrounds-basic \
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
    gvfs-mtp \
    htop \
    joystick-support \
    kernel-modules-extra \
    kitty \
    liberation-fonts \
    libmtp \
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
# removed hyprland-qtutils from Fedora 43 release because of compatiblity issues
if [[ "${HYPRLAND_BUILD}" == "git" ]]; then
    rpm-ostree install hyprlock hypridle hyprpaper hyprshot xdg-desktop-portal-hyprland hyprland-git
elif [[ "${HYPRLAND_BUILD}" == "solopasha" ]]; then
    rpm-ostree install hyprlock hypridle hyprpaper hyprshot xdg-desktop-portal-hyprland hyprland
fi

#Install COPR packages from cjuniorfox/hyprland-shell
rpm-ostree install bibata-cursor-theme hyprland-shell-config install-flatpak-package wol-changer


# Remove the Firefox related packages (will be installed over flatpak)
rpm-ostree override remove firefox-langpacks firefox

#Enable the Installation of the flatpak component org.freedesktop.Platform.openh264 
# after the first boot, this is needed because the flatpak version of Firefox depends # 
# of the openh264 codec, which is not available for offline installation
systemctl enable install-flatpak-package@runtime-org.freedesktop.Platform.openh264-x86_64-2.5.1

# ============================================================================
# Enable mDNS (systemd-resolved + NSS)
# ============================================================================
# This section configures the system to resolve .local domains using mDNS
# (Avahi/Bonjour) which is essential for discovering devices on the local
# network (printers, IoT devices, etc.). It enables both IPv4 and IPv6 mDNS
# resolution.
#
# What this does:
# 1. Creates systemd-resolved drop-in configuration to enable MulticastDNS
# 2. Updates /etc/nsswitch.conf to prefer mdns lookups before systemd-resolved
# 3. Systemd-resolved will be enabled and started on first boot
#
# This configuration is idempotent and safe to run multiple times.
# ============================================================================

echo "=== Configuring mDNS support for systemd-resolved and NSSwitch ==="

# Step 1: Configure systemd-resolved to enable MulticastDNS
RESOLVED_CONF_DIR="/etc/systemd/resolved.conf.d"
RESOLVED_CONF_FILE="${RESOLVED_CONF_DIR}/dns.conf"

echo "Creating systemd-resolved configuration..."
mkdir -p "${RESOLVED_CONF_DIR}"

# Create the drop-in configuration file (idempotent - always overwrite with correct content)
cat > "${RESOLVED_CONF_FILE}" <<'RESOLVED_EOF'
# Enable multicast DNS (mDNS) for .local domain resolution
# This allows resolving hostnames like hostname.local using Avahi/Bonjour
# Supports both IPv4 and IPv6
[Resolve]
MulticastDNS=yes
RESOLVED_EOF

echo "  Created/updated: ${RESOLVED_CONF_FILE}"

# Step 2: Update /etc/nsswitch.conf to prefer mdns before resolve
NSSWITCH_CONF="/etc/nsswitch.conf"

echo "Updating NSSwitch configuration..."

if [[ ! -f "${NSSWITCH_CONF}" ]]; then
    echo "  WARNING: ${NSSWITCH_CONF} not found, creating default..." >&2
    # Create a minimal nsswitch.conf with mDNS enabled
    cat > "${NSSWITCH_CONF}" <<'NSSWITCH_EOF'
# Minimal nsswitch.conf with mDNS support
passwd:     files systemd
group:      files systemd
shadow:     files systemd

hosts:      files mdns [NOTFOUND=return] resolve [!UNAVAIL=return] dns myhostname
networks:   files

protocols:  files
services:   files
ethers:     files
rpc:        files

netgroup:   files
NSSWITCH_EOF
    echo "  Created: ${NSSWITCH_CONF}"
else
    # Check if the hosts line already contains mdns
    if grep -q "^hosts:.*mdns" "${NSSWITCH_CONF}"; then
        echo "  NSSwitch already configured with mdns, skipping modification"
    else
        # Create timestamped backup before modification
        NSSWITCH_BACKUP="${NSSWITCH_CONF}.backup-$(date +%Y%m%d-%H%M%S)"
        cp -p "${NSSWITCH_CONF}" "${NSSWITCH_BACKUP}"
        echo "  Created backup: ${NSSWITCH_BACKUP}"
        
        # Update the hosts line to include mdns before resolve
        # Target pattern: hosts: files mdns [NOTFOUND=return] resolve [!UNAVAIL=return] dns myhostname
        # This prioritizes local files, then mDNS, then systemd-resolved, then DNS, then myhostname
        
        if grep -q "^hosts:" "${NSSWITCH_CONF}"; then
            # Replace existing hosts line
            sed -i 's/^hosts:.*$/hosts:      files mdns [NOTFOUND=return] resolve [!UNAVAIL=return] dns myhostname/' "${NSSWITCH_CONF}"
            echo "  Updated hosts line in: ${NSSWITCH_CONF}"
        else
            # Add hosts line if it doesn't exist
            echo "hosts:      files mdns [NOTFOUND=return] resolve [!UNAVAIL=return] dns myhostname" >> "${NSSWITCH_CONF}"
            echo "  Added hosts line to: ${NSSWITCH_CONF}"
        fi
    fi
fi

echo "  NSSwitch configuration completed"

# Step 3: Enable systemd-resolved (will start on first boot)
# Note: We're in a container build environment, so systemd is not running.
# The service will be enabled and will start when the image boots.
echo "Enabling systemd-resolved for first boot..."

# Check if systemctl is available before attempting to enable
if command -v systemctl &> /dev/null; then
    systemctl enable systemd-resolved 2>/dev/null || echo "  Note: systemd-resolved enable skipped (may already be enabled)"
    echo "  systemd-resolved will be active on first boot"
else
    echo "  systemctl not available in build environment - service will be enabled by default"
fi

echo ""
echo "=== mDNS configuration completed successfully ==="
echo ""
echo "Post-boot validation commands (run these after the system boots):"
echo "  1. Check systemd-resolved status:"
echo "     resolvectl status"
echo ""
echo "  2. Test mDNS resolution (requires avahi-tools):"
echo "     avahi-resolve -n <hostname>.local"
echo ""
echo "  3. Test hostname resolution via NSSwitch:"
echo "     getent hosts <hostname>.local"
echo ""
echo "Note: mDNS requires avahi-daemon to be installed and running."
echo ""
