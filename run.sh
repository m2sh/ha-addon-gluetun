#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Gluetun VPN
# ==============================================================================

# Initialize variables
declare vpn_provider
declare vpn_type
declare openvpn_user
declare openvpn_password
declare wireguard_private_key
declare wireguard_addresses
declare shadowsocks_enabled
declare http_proxy_enabled
declare http_proxy_port
declare dns_providers
declare tz

# Load configuration values
vpn_provider=$(bashio::config 'vpn_provider')
vpn_type=$(bashio::config 'vpn_type')
openvpn_user=$(bashio::config 'openvpn_user')
openvpn_password=$(bashio::config 'openvpn_password')
wireguard_private_key=$(bashio::config 'wireguard_private_key')
wireguard_addresses=$(bashio::config 'wireguard_addresses')
shadowsocks_enabled=$(bashio::config 'shadowsocks_enabled')
http_proxy_enabled=$(bashio::config 'http_proxy_enabled')
http_proxy_port=$(bashio::config 'http_proxy_port')
dns_providers=$(bashio::config 'dns_providers')
tz=$(bashio::config 'tz')

# Set timezone
if bashio::var.has_value "${tz}"; then
    export TZ="${tz}"
fi

# Generate Gluetun configuration
bashio::log.info "Generating Gluetun configuration..."
/gluetun-config.sh

# Start Gluetun
bashio::log.info "Starting Gluetun VPN client..."
exec s6-setuidgid abc gluetun 