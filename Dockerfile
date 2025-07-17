# Multi-stage build for Gluetun from source
FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git

# Build Gluetun from source (shallow clone)
ARG GLUETUN_VERSION=v3.40.0
RUN git clone --depth 1 --branch ${GLUETUN_VERSION} https://github.com/qdm12/gluetun.git /tmp/gluetun && \
    cd /tmp/gluetun && \
    go build -o /gluetun ./cmd/gluetun

# Final stage
FROM alpine:3.20

# Install s6-overlay
ENV S6_OVERLAY_VERSION=v3.1.5.0
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm -rf /tmp/s6-overlay-*.tar.xz

# Install required packages
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-flask \
    py3-requests \
    curl \
    jq \
    bash \
    openvpn \
    wireguard-tools \
    iptables \
    ip6tables \
    net-tools \
    procps

# Install Python dependencies for our web API
RUN pip3 install --break-system-packages flask-cors

# Copy the built Gluetun binary from builder stage
COPY --from=builder /gluetun /usr/local/bin/gluetun
RUN chmod 755 /usr/local/bin/gluetun

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

# Use s6-overlay as entrypoint
ENTRYPOINT ["/init"] 