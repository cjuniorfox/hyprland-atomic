mkdir ./iso-output
sudo podman run --rm --privileged --volume ./iso-output:/build-container-installer/build --security-opt label=disable --pull=newer \
ghcr.io/jasonn3/build-container-installer:latest \
IMAGE_REPO=ghcr.io/cjuniorfox \
IMAGE_NAME=hyprland-atomic \
IMAGE_TAG=latest \
VARIANT=base-main # should match the variant your image is based on