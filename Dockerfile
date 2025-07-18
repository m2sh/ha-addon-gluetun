ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-flask \
    py3-requests \
    openvpn \
    wireguard-tools \
    iptables \
    ip6tables \
    net-tools \
    procps \
    unzip

# Install Python dependencies for our web API
RUN pip3 install --break-system-packages flask-cors

# Download and install Gluetun binary
ARG GLUETUN_VERSION=v3.40.0
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
        "amd64") GLUETUN_ARCH="amd64" ;; \
        "arm64") GLUETUN_ARCH="arm64" ;; \
        "arm") GLUETUN_ARCH="armv6" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    wget -O /tmp/gluetun.zip "https://github.com/qdm12/gluetun/releases/download/${GLUETUN_VERSION}/gluetun_${GLUETUN_VERSION}_linux_${GLUETUN_ARCH}.zip" && \
    unzip /tmp/gluetun.zip -d /tmp/ && \
    mv /tmp/gluetun /usr/local/bin/gluetun && \
    chmod 755 /usr/local/bin/gluetun && \
    rm -rf /tmp/gluetun.zip

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
EXPOSE 8888 8388

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