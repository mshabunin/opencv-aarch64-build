FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    git \
    ccache \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    qemu-user \
    pkg-config

RUN apt-get install -y autoconf libtool g++ gcc scons

RUN dpkg --add-architecture arm64 && \
    sed -i 's/deb /deb [arch=amd64] /' /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy universe" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-updates universe" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-updates multiverse" >> /etc/apt/sources.list && \
    apt-get update

RUN apt-get install -y \
    libgstreamer-plugins-base1.0-dev:arm64 \
    libgstreamer-plugins-good1.0-dev:arm64 \
    libgstreamer1.0-dev:arm64 \
    libeigen3-dev:arm64 \
    libgtk-3-dev:arm64 \
    x11proto-dev:arm64 \
    libavformat-dev:arm64 \
    libavfilter-dev:arm64 \
    libavdevice-dev:arm64 \
    libavcodec-dev:arm64 \
    libavutil-dev:arm64 \
    libswresample-dev:arm64 \
    libglib2.0-dev:arm64 \
    libpython3-dev:arm64 \
    python3-numpy
