# Hyprland Atomic Image

## Purpose

This repository is dedicated to building and customizing a Universal Blue image using Hyprland as the desktop compositor. The goal is to create a Fedora Atomic-based distribution with Hyprland, providing a modern and efficient desktop environment.

## Download Links

You can download the latest version of the distribution and its checksum from the following links:

### Hyperland Fedora 40

- [Hyprland Atomic Fedora ISO](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-fedora-x86_64-40-latest.iso)
- [Hyprland Atomic Fedora ISO Checksum](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-fedora-x86_64-40-latest.iso-CHECKSUM)

### Hyperland Solopasha 40

- [Hyprland Atomic Solopasha ISO](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-solopasha-x86_64-40-latest.iso)
- [Hyprland Atomic Solopasha ISO Checksum](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-solopasha-x86_64-40-latest.iso-CHECKSUM)

### Hyperland Solopasha Git Build 40

- [Hyprland Atomic Solopasha ISO](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-git-x86_64-40-latest.iso)
- [Hyprland Atomic Solopasha ISO Checksum](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-git-x86_64-40-latest.iso-CHECKSUM)

### Hyperland Solopasha 40 with Virtualization

- [Hyprland Atomic Solopasha ISO](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-solopasha-virt-x86_64-40-latest.iso)
- [Hyprland Atomic Solopasha ISO Checksum](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-solopasha-virt-x86_64-40-latest.iso-CHECKSUM)

### Hyperland Git Build 40 with Virtualization

- [Hyprland Atomic Solopasha ISO](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-git-virt-x86_64-40-latest.iso)
- [Hyprland Atomic Solopasha ISO Checksum](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-git-virt-x86_64-40-latest.iso-CHECKSUM)

## Rebase

If you're using Silverblue or alike, you can rebase to this repository doing the following:

```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/cjuniorfox/hyprland-atomic-fedora:latest
```

## Rebase
If you're using Silverblue or alike, you can rebase to this repository doing the following:
```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/cjuniorfox/hyprland-atomic:latest
```

## Features

- **Immutable System**: Built on Fedora Atomic, ensuring a stable and secure environment.
- **Hyprland Compositor**: Utilizes Hyprland for a modern and efficient desktop experience.
- **Pre-installed Packages**: Comes with a set of pre-installed packages tailored for a seamless user experience.
- **Containerized Applications**: Leverages container technology for application management and isolation.

## Prerequisites

To fully utilize this distribution, it is recommended to have a working knowledge in the following areas:

- Containers: [Introduction to Containers](https://www.youtube.com/watch?v=SnSH8Ht3MIc)
- rpm-ostree: [rpm-ostree Documentation](https://coreos.github.io/rpm-ostree/container/)
- Fedora Silverblue: [Fedora Silverblue Documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/)
- GitHub Workflows: [GitHub Actions Documentation](https://docs.github.com/en/actions/using-workflows)

## How to Use

1. **Download the ISO**: Use the download links provided above to get the latest version of the Hyprland Atomic ISO.
2. **Verify the ISO**: Use the checksum link to verify the integrity of the downloaded ISO.
3. **Create a Bootable USB**: Use tools like `dd` or `Rufus` to create a bootable USB drive from the ISO.
4. **Install the Distribution**: Boot from the USB drive and follow the installation instructions to set up Hyprland Atomic on your system.

## Contributing

We welcome contributions to improve this project. Feel free to open issues or submit pull requests on our GitHub repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

This project is inspired by the Universal Blue Project and leverages various open-source technologies to deliver a robust and modern desktop experience.
