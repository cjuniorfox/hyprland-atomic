ARG SOURCE_IMAGE="base"
ARG SOURCE_SUFFIX="-main"
ARG SOURCE_TAG="42"

FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

ARG HYPRLAND_BUILD="fedora"
ARG VIRTUALIZATION="no"

ENV HYPRLAND_BUILD=${HYPRLAND_BUILD}
ENV VIRTUALIZATION=${VIRTUALIZATION}

COPY build.sh /tmp/build.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit