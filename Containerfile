## 1. BUILD ARGS
ARG SOURCE_IMAGE="base"
ARG SOURCE_SUFFIX="-main"
ARG RELEASE="40"
ARG HYPRLAND_BUILD="fedora"
ARG VIRTUALIZATION="no"

## 2. SOURCE IMAGE
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${RELEASE}

## 3. Set environment variables
ENV RELEASE=${RELEASE}
ENV HYPRLAND_BUILD=${HYPRLAND_BUILD}
ENV VIRTUALIZATION=${VIRTUALIZATION}

## 4. Copy and run the build script
COPY build.sh /tmp/build.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit