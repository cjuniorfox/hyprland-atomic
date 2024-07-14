# Hyprland Atomic Image

## Purpose
This repository is meant to build and customize a Universal Blue image using Hyprland as the desktop compositor. The goal is to create a Fedora Atomic-based distribution with Hyprland, providing a modern and efficient desktop environment.

## Download Links
You can download the latest version of the distribution and its checksum from the following links:
- [Hyprland Atomic ISO](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-x86_64-40-latest.iso)
- [Hyprland Atomic ISO Checksum](https://juniorfox-net-isos.s3.sa-east-1.amazonaws.com/hyprland-atomic-x86_64-40-latest.iso-CHECKSUM)

## Prerequisites
Working knowledge in the following topics:
- Containers - https://www.youtube.com/watch?v=SnSH8Ht3MIc
- https://www.mankier.com/5/Containerfile
- rpm-ostree - https://coreos.github.io/rpm-ostree/container/
- Fedora Silverblue (and other Fedora Atomic variants) - https://docs.fedoraproject.org/en-US/fedora-silverblue/
- Github Workflows - https://docs.github.com/en/actions/using-workflows

## How to Use
For more detailed instructions and the original repository, please visit [Universal Blue Main Repository](https://github.com/ublue-os/main).

### Containerfile
This file defines the operations used to customize the selected image. It contains examples of possible modifications, including how to:
- change the upstream from which the custom image is derived
- add additional RPM packages
- add binaries as a layer from other images

### Workflows
#### build.yml
This workflow creates your custom OCI image and publishes it to the Github Container Registry (GHCR). By default, the image name will match the Github repository name.

##### Container Signing
Container signing is important for end-user security and is enabled on all Universal Blue images. It is recommended you set this up, and by default the image builds *will fail* if you don't. This provides users a method of verifying the image.

1. Install the [cosign CLI tool](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-install-cosign/#installing-cosign-with-the-cosign-binary)
2. Run inside your repo folder:
``bash
cosign generate-key-pair
``
- Do NOT put in a password when it asks you to, just press enter. The signing key will be used in GitHub Actions and will not work if it is encrypted.
> [!WARNING]
> Be careful to *never* accidentally commit `cosign.key` into your git repo.
3. Add the private key to GitHub
- This can also be done manually. Go to your repository settings, under Secrets and Variables -> Actions
![image](https://user-images.githubusercontent.com/1264109/216735595-0ecf1b66-b9ee-439e-87d7-c8cc43c2110a.png)
Add a new secret and name it `SIGNING_SECRET`, then paste the contents of `cosign.key` into the secret and save it. Make sure it's the .key file and not the .pub file. Once done, it should look like this:
![image](https://user-images.githubusercontent.com/1264109/216735690-2d19271f-cee2-45ac-a039-23e6a4c16b34.png)
- (CLI instructions) If you have the `github-cli` installed, run:
``bash
gh secret set SIGNING_SECRET < cosign.key
``
4. Commit the `cosign.pub` file into your git repository