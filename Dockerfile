FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libgtk-3-dev \
    curl \
    unzip \
    git \
    tzdata \
    clang \
    ninja-build \
    pkg-config \
    liblzma-dev \
    xz-utils \
    libx11-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxdamage-dev \
    libxcomposite-dev \
    libasound2-dev \
    libpulse-dev \
    libdbus-1-dev \
    libnspr4-dev \
    libnss3-dev \
    libatk1.0-dev \
    libatk-bridge2.0-dev \
    libdrm-dev \
    libgbm-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Set up new user for better security
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Copy local Flutter SDK into the container
# Configure git to use HTTPS
RUN git config --global http.sslVerify false

# Now try cloning Flutter
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /home/developer/flutter

RUN cd /home/developer/flutter && git checkout stable


# Add Flutter to PATH
ENV PATH="/home/developer/flutter/bin:${PATH}"

# Create app directory
RUN mkdir -p /home/developer/app
WORKDIR /home/developer/app

# Copy project files into the container
COPY --chown=developer:developer pubspec.yaml /home/developer/app/
COPY --chown=developer:developer linux /home/developer/app/
COPY --chown=developer:developer lib/ /home/developer/app/lib/
COPY --chown=developer:developer . .

# Enable Linux desktop support and configure Flutter
RUN flutter config --enable-linux-desktop \
    && flutter config --no-analytics \
    && yes | flutter doctor \
    && flutter precache

# Run Flutter build
RUN flutter clean && \
    flutter pub get \
    && flutter build linux 