#!/usr/bin/env bashio

# Generate Gluetun configuration based on Home Assistant config

# VPN Service Provider
if bashio::var.has_value "${vpn_provider}"; then
    export VPN_SERVICE_PROVIDER="${vpn_provider}"
fi

# VPN Type
if bashio::var.has_value "${vpn_type}"; then
    export VPN_TYPE="${vpn_type}"
fi

# OpenVPN credentials
if bashio::var.has_value "${openvpn_user}"; then
    export OPENVPN_USER="${openvpn_user}"
fi

if bashio::var.has_value "${openvpn_password}"; then
    export OPENVPN_PASSWORD="${openvpn_password}"
fi

# Wireguard configuration
if bashio::var.has_value "${wireguard_private_key}"; then
    export WIREGUARD_PRIVATE_KEY="${wireguard_private_key}"
fi

if bashio::var.has_value "${wireguard_addresses}"; then
    export WIREGUARD_ADDRESSES="${wireguard_addresses}"
fi

# Shadowsocks configuration
if bashio::var.has_value "${shadowsocks_enabled}"; then
    if [ "${shadowsocks_enabled}" = "true" ]; then
        export SHADOWSOCKS_ENABLED="on"
        
        # Shadowsocks port
        if bashio::var.has_value "${shadowsocks_port}"; then
            export SHADOWSOCKS_PORT="${shadowsocks_port}"
        else
            export SHADOWSOCKS_PORT="8388"
        fi
        
        # Shadowsocks password
        if bashio::var.has_value "${shadowsocks_password}"; then
            export SHADOWSOCKS_PASSWORD="${shadowsocks_password}"
        else
            export SHADOWSOCKS_PASSWORD="gluetun"
        fi
        
        # Shadowsocks encryption method
        if bashio::var.has_value "${shadowsocks_method}"; then
            export SHADOWSOCKS_METHOD="${shadowsocks_method}"
        else
            export SHADOWSOCKS_METHOD="aes-256-gcm"
        fi
    else
        export SHADOWSOCKS_ENABLED="off"
    fi
fi

# HTTP Proxy configuration
if bashio::var.has_value "${http_proxy_enabled}"; then
    if [ "${http_proxy_enabled}" = "true" ]; then
        export HTTPPROXY_ENABLED="on"
        if bashio::var.has_value "${http_proxy_port}"; then
            export HTTPPROXY_PORT="${http_proxy_port}"
        else
            export HTTPPROXY_PORT="8888"
        fi
    else
        export HTTPPROXY_ENABLED="off"
    fi
fi

# DNS configuration
if bashio::var.has_value "${dns_providers}"; then
    export DOT="${dns_providers}"
fi

# Additional Gluetun settings
export UPDATER_PERIOD="24h"
export BLOCK_MALICIOUS="on"
export BLOCK_ADS="on"
export BLOCK_SURVEILLANCE="on"

# Log configuration
export LOG_LEVEL="info"

bashio::log.info "Gluetun configuration generated successfully" 