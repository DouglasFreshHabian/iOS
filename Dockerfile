FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Everything source-built goes here.
ENV PREFIX=/opt/libimobiledevice

# Make the source-built tools and libraries available automatically
# in every container created from this image.
ENV PATH="/opt/libimobiledevice/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/libimobiledevice/lib"
ENV PKG_CONFIG_PATH="/opt/libimobiledevice/lib/pkgconfig"

# ---------------------------------------------------------------------------
# Build dependencies
# ---------------------------------------------------------------------------

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    git \
    autoconf \
    automake \
    libtool-bin \
    libssl-dev \
    libcurl4-openssl-dev \
    libreadline-dev \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Build the current upstream stack
# ---------------------------------------------------------------------------

WORKDIR /tmp

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libplist.git; \
    cd libplist; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd ..; \
    rm -rf libplist

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libimobiledevice-glue.git; \
    cd libimobiledevice-glue; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd ..; \
    rm -rf libimobiledevice-glue

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libusbmuxd.git; \
    cd libusbmuxd; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd ..; \
    rm -rf libusbmuxd

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libtatsu.git; \
    cd libtatsu; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd ..; \
    rm -rf libtatsu

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libimobiledevice.git; \
    cd libimobiledevice; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd ..; \
    rm -rf libimobiledevice

# ---------------------------------------------------------------------------
# Runtime library configuration
# ---------------------------------------------------------------------------

RUN echo "/opt/libimobiledevice/lib" \
        > /etc/ld.so.conf.d/libimobiledevice.conf \
 && ldconfig

# ---------------------------------------------------------------------------
# Start in a shell
# ---------------------------------------------------------------------------

WORKDIR /root

CMD ["/bin/bash"]
