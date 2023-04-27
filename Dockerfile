FROM ubuntu:20.04

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
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal main restricted" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal universe" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse" >> /etc/apt/sources.list && \
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
    libavresample-dev:arm64 \
    libavutil-dev:arm64 \
    libglib2.0-dev:arm64
