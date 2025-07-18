# Multi-stage build for Gluetun from source
ARG GLUETUN_VERSION=v3.40.0
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

# Build Gluetun from source
RUN git clone --depth 1 --branch ${GLUETUN_VERSION} https://github.com/qdm12/gluetun.git /tmp/gluetun && \
    cd /tmp/gluetun && \
    go build -o /gluetun ./cmd/gluetun

# Final stage - use Home Assistant base image
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Install required packages based on official Gluetun Dockerfile
RUN apk add --no-cache --update \
    wget \
    ca-certificates \
    iptables \
    iptables-legacy \
    tzdata \
    python3 \
    py3-pip \
    py3-flask \
    py3-requests \
    wireguard-tools \
    net-tools \
    procps

# Install OpenVPN 2.5 and 2.6 like official Gluetun
RUN apk add --no-cache --update -X "https://dl-cdn.alpinelinux.org/alpine/v3.17/main" openvpn~2.5 && \
    mv /usr/sbin/openvpn /usr/sbin/openvpn2.5 && \
    apk del openvpn && \
    apk add --no-cache --update openvpn && \
    mv /usr/sbin/openvpn /usr/sbin/openvpn2.6 && \
    rm -rf /var/cache/apk/* /etc/openvpn/*.sh /usr/lib/openvpn/plugins/openvpn-plugin-down-root.so && \
    deluser openvpn 2>/dev/null || true

# Install Python dependencies for our web API
RUN pip3 install --break-system-packages flask-cors

# Copy Gluetun binary from builder stage
COPY --from=builder /gluetun /usr/local/bin/gluetun
RUN chmod 755 /usr/local/bin/gluetun

# Create gluetun directory like official image
RUN mkdir -p /gluetun

# Copy our integration files
COPY run.sh /addon/run.sh
COPY startup.sh /addon/startup.sh
COPY gluetun-config.sh /addon/gluetun-config.sh
COPY web/ /web/
RUN chmod a+x /addon/*.sh

# s6 service definitions
COPY s6-services/ /etc/services.d/
RUN chmod +x /etc/services.d/*/run

# Set working directory
WORKDIR /app

# Expose ports
EXPOSE 8888 8388 8000

# Set environment variables similar to official Gluetun
ENV VPN_SERVICE_PROVIDER=pia \
    VPN_TYPE=openvpn \
    VPN_INTERFACE=tun0 \
    OPENVPN_VERSION=2.6 \
    OPENVPN_VERBOSITY=1 \
    OPENVPN_PROTOCOL=udp \
    FIREWALL_ENABLED_DISABLING_IT_SHOOTS_YOU_IN_YOUR_FOOT=on \
    LOG_LEVEL=info \
    HEALTH_SERVER_ADDRESS=127.0.0.1:9999 \
    HEALTH_TARGET_ADDRESS=cloudflare.com:443 \
    DOT=on \
    DOT_PROVIDERS=cloudflare \
    HTTPPROXY=off \
    SHADOWSOCKS=off \
    HTTP_CONTROL_SERVER_ADDRESS=":8000" \
    PUBLICIP_FILE="/tmp/gluetun/ip" \
    PUBLICIP_ENABLED=on \
    STORAGE_FILEPATH=/gluetun/servers.json \
    VERSION_INFORMATION=on

# Add Home Assistant labels
LABEL \
    io.hass.name="Gluetun VPN" \
    io.hass.description="VPN client for multiple providers with proxy services" \
    io.hass.arch="armhf|armv7|aarch64|amd64|i386" \
    io.hass.type="addon" \
    io.hass.version="1.0.0" \
    maintainer="Mohammad Shahgolzadeh <m2sh>" \
    org.opencontainers.image.title="Gluetun VPN" \
    org.opencontainers.image.description="VPN client for multiple providers with proxy services" \
    org.opencontainers.image.source="https://github.com/m2sh/ha-addon-gluetun" \
    org.opencontainers.image.licenses="MIT"

# Use s6-overlay as entrypoint
ENTRYPOINT ["/init"] 