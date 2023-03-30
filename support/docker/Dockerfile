# SPDX-License-Identifier: GPL-2.0-or-later
# copied from Buildroot 2023.02-rc3
# and then updated:
# - to contain this license header
# - to not point to Buildroot mailing list or registry
# - to use up-to-date base image (debian unstable = bookworm)
# - to use 'sed' to select snapshot apt mirror
# - to allow multiple layers on docker to improve regeneration of image
# - to use the minimal number of packages installed

# This Dockerfile generates the docker image that gets used by Gitlab CI
# Build it using 'make docker-image'

# latest snapshot from https://hub.docker.com/_/debian
FROM debian:bookworm-20230320

# select snapshot apt mirror
RUN sed \
        -e 's,^URIs: .*,# \0,g' \
        -e 's,^# \(http.*snapshot.*\),URIs: \1,g' \
        -i /etc/apt/sources.list.d/debian.sources

# The container has no package lists, so need to update first
RUN apt-get -o APT::Retries=3 update -y

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        build-essential \
        && echo done installing basic build dependencies

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        git \
        && echo done installing basic gitlab CI dependencies

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        bc \
        ca-certificates \
        cpio \
        file \
        rsync \
        unzip \
        wget \
        && echo done installing make source dependencies

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        libncurses5-dev \
        && echo done installing make menuconfig dependencies

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        expect \
        && echo done installing brmake dependencies

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        cmake \
        lzip \
        && echo done installing pre-built build tools

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        qemu-system-arm \
        && echo done installing pre-built runtime test tools

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
        python3 \
        python3-flake8 \
        python3-magic \
        python3-six \
        shellcheck \
        && echo done installing check-package dependencies

RUN useradd -ms /bin/bash br-user && \
    chown -R br-user:br-user /home/br-user

USER br-user
WORKDIR /home/br-user
ENV HOME /home/br-user
