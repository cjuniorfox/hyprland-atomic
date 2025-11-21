#!/bin/bash

# Enable mDNS (multicast DNS) support for systemd-resolved and NSSwitch
#
# This script configures the system to resolve .local domains using mDNS (Avahi/Bonjour)
# which is essential for discovering devices on the local network (printers, IoT devices, etc.)
# It enables both IPv4 and IPv6 mDNS resolution.
#
# What this script does:
# 1. Creates systemd-resolved drop-in configuration to enable MulticastDNS
# 2. Updates /etc/nsswitch.conf to prefer mdns lookups before systemd-resolved
# 3. Restarts systemd-resolved if systemd is available and running
#
# This script is idempotent and safe to run multiple times.

set -euo pipefail

# Check for root privileges
if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: This script must be run as root (requires EUID=0)" >&2
    echo "Please run with: sudo $0" >&2
    exit 1
fi

echo "=== Enabling mDNS support for systemd-resolved and NSSwitch ==="

# Step 1: Configure systemd-resolved to enable MulticastDNS
RESOLVED_CONF_DIR="/etc/systemd/resolved.conf.d"
RESOLVED_CONF_FILE="${RESOLVED_CONF_DIR}/dns.conf"

echo "Creating systemd-resolved configuration..."
if [[ ! -d "${RESOLVED_CONF_DIR}" ]]; then
    mkdir -p "${RESOLVED_CONF_DIR}"
    echo "  Created directory: ${RESOLVED_CONF_DIR}"
fi

# Create the drop-in configuration file (idempotent - always overwrite with correct content)
cat > "${RESOLVED_CONF_FILE}" <<'EOF'
# Enable multicast DNS (mDNS) for .local domain resolution
# This allows resolving hostnames like hostname.local using Avahi/Bonjour
# Supports both IPv4 and IPv6
[Resolve]
MulticastDNS=yes
EOF

echo "  Created/updated: ${RESOLVED_CONF_FILE}"

# Step 2: Update /etc/nsswitch.conf to prefer mdns before resolve
NSSWITCH_CONF="/etc/nsswitch.conf"
NSSWITCH_BACKUP="${NSSWITCH_CONF}.backup-$(date +%Y%m%d-%H%M%S)"

echo "Updating NSSwitch configuration..."

# Check if nsswitch.conf exists
if [[ ! -f "${NSSWITCH_CONF}" ]]; then
    echo "  WARNING: ${NSSWITCH_CONF} not found, creating default..." >&2
    # Create a minimal nsswitch.conf with mDNS enabled
    cat > "${NSSWITCH_CONF}" <<'EOF'
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
EOF
    echo "  Created: ${NSSWITCH_CONF}"
else
    # Backup the original file only if it hasn't been modified yet
    # Check if the hosts line already contains mdns
    if grep -q "^hosts:.*mdns" "${NSSWITCH_CONF}"; then
        echo "  NSSwitch already configured with mdns, skipping backup and modification"
    else
        # Create backup before modification
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

# Step 3: Restart systemd-resolved if systemd is available and running
echo "Checking systemd availability..."

# Check if systemctl is available and systemd is running
if command -v systemctl &> /dev/null; then
    # Check if we're in a systemd environment (not all containers have systemd)
    if systemctl is-system-running &> /dev/null || systemctl status &> /dev/null; then
        echo "  Systemd is available, enabling and restarting systemd-resolved..."
        
        # Enable systemd-resolved to start on boot
        systemctl enable systemd-resolved 2>/dev/null || true
        
        # Restart systemd-resolved to apply the new configuration
        systemctl restart systemd-resolved 2>/dev/null || echo "  Note: Could not restart systemd-resolved (may not be active yet)"
        
        echo "  Systemd-resolved configured successfully"
    else
        echo "  Systemd is not running (container/chroot environment)"
        echo "  Configuration files created but systemd-resolved not started"
        echo "  Services will be activated on first boot"
    fi
else
    echo "  systemctl not found - likely a container build environment"
    echo "  Configuration files created, services will be activated on first boot"
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
echo "Install with: rpm-ostree install avahi (or use your package manager)"
echo ""
