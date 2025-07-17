# Gluetun VPN Home Assistant Addon

A Home Assistant addon that provides a lightweight VPN client for multiple VPN service providers using [Gluetun](https://github.com/qdm12/gluetun).

## Features

- **Multiple VPN Providers**: Support for 25+ VPN providers including NordVPN, ExpressVPN, Mullvad, ProtonVPN, and more
- **Dual VPN Protocols**: OpenVPN and Wireguard support
- **Proxy Services**: Built-in Shadowsocks and HTTP proxy servers
- **DNS over TLS**: Secure DNS with multiple provider options
- **Kill Switch**: Built-in firewall to ensure traffic only goes through VPN
- **Health Monitoring**: Real-time status monitoring and metrics
- **User-Friendly Interface**: Web-based configuration panel
- **Auto-Reconnection**: Automatic reconnection on connection loss

## Supported VPN Providers

- AirVPN
- Cyberghost
- ExpressVPN
- FastestVPN
- Giganews
- HideMyAss
- IPVanish
- IVPN
- Mullvad
- NordVPN
- Perfect Privacy
- Privado
- Private Internet Access
- PrivateVPN
- ProtonVPN
- PureVPN
- SlickVPN
- Surfshark
- TorGuard
- VPNSecure.me
- VPNUnlimited
- Vyprvpn
- WeVPN
- Windscribe

## Installation

1. Add this repository to your Home Assistant addon store
2. Install the "Gluetun VPN" addon
3. Configure your VPN provider settings
4. Start the addon

## Configuration

### Basic Configuration

```yaml
vpn_provider: "nordvpn"
vpn_type: "openvpn"
openvpn_user: "your_username"
openvpn_password: "your_password"
```

### Advanced Configuration

```yaml
# VPN Configuration
vpn_provider: "nordvpn"
vpn_type: "openvpn"  # or "wireguard"
openvpn_user: "your_username"
openvpn_password: "your_password"

# Wireguard Configuration (if using wireguard)
wireguard_private_key: "your_private_key"
wireguard_addresses: "10.64.222.21/32"

# Proxy Services
shadowsocks_enabled: true
http_proxy_enabled: true
http_proxy_port: 8888

# DNS Configuration
dns_providers: "cloudflare,google,quad9"

# General Settings
tz: "America/New_York"
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vpn_provider` | string | - | VPN service provider (required) |
| `vpn_type` | string | `openvpn` | VPN protocol type (`openvpn` or `wireguard`) |
| `openvpn_user` | string | - | OpenVPN username |
| `openvpn_password` | string | - | OpenVPN password |
| `wireguard_private_key` | string | - | Wireguard private key |
| `wireguard_addresses` | string | - | Wireguard IP addresses |
| `shadowsocks_enabled` | boolean | `false` | Enable Shadowsocks proxy |
| `http_proxy_enabled` | boolean | `false` | Enable HTTP proxy |
| `http_proxy_port` | number | `8888` | HTTP proxy port |
| `dns_providers` | string | - | DNS providers (comma-separated) |
| `tz` | string | - | Timezone |

## Usage

### Web Interface

The addon provides a web interface accessible through Home Assistant's addon panel. The interface includes:

- **Status Dashboard**: Real-time connection status and metrics
- **Configuration Panel**: Easy-to-use form for all settings
- **Provider Selection**: Dropdown menu with all supported providers
- **Proxy Configuration**: Toggle and configure proxy services

### API Endpoints

The addon exposes several API endpoints:

- `GET /api/config` - Get current configuration
- `POST /api/config` - Update configuration
- `GET /api/status` - Get VPN status
- `POST /api/restart` - Restart Gluetun service

### Home Assistant Integration

Add the following to your `configuration.yaml`:

```yaml
sensor:
  - platform: gluetun
    name: "VPN Status"
    host: "localhost"
    port: 8000
    update_interval: 30
```

This will create a sensor that monitors:
- Connection status (Connected/Disconnected)
- Connected server
- Public IP address
- Uptime
- VPN provider
- Last update time

## Proxy Services

### Shadowsocks Proxy

When enabled, Shadowsocks proxy is available on port 8388 with the following configuration:

- **Method**: aes-256-gcm
- **Password**: gluetun
- **Port**: 8388 (TCP/UDP)

### HTTP Proxy

When enabled, HTTP proxy is available on the configured port (default: 8888).

## DNS Configuration

The addon supports DNS over TLS with multiple providers. Common providers include:

- `cloudflare`
- `google`
- `quad9`
- `adguard`
- `cleanbrowsing`

You can specify multiple providers separated by commas.

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Verify your VPN credentials
   - Check if your VPN provider is supported
   - Ensure your subscription is active

2. **Addon Won't Start**
   - Check the logs for error messages
   - Verify the configuration is valid
   - Ensure the required ports are available

3. **Proxy Not Working**
   - Verify the proxy service is enabled
   - Check if the ports are not blocked
   - Test with a simple HTTP request

### Logs

View the addon logs in Home Assistant:
1. Go to **Settings** > **Add-ons** > **Gluetun VPN**
2. Click on the **Logs** tab
3. Look for error messages or connection issues

### Manual Configuration

If the web interface doesn't work, you can manually edit the configuration:

1. Stop the addon
2. Edit the configuration in the addon settings
3. Start the addon

## Development

### Building the Addon

```bash
# Clone the repository
git clone <repository-url>
cd ha-addon-glutun

# Build the addon locally (builds Gluetun from source)
docker build -t gluetun-addon .

# Or build using Home Assistant's build system
docker build -t gluetun-addon .
```

**Note**: 
- The unified Dockerfile builds Gluetun from source and works for both local development and Home Assistant addon builds
- All builds use the same Dockerfile with multi-stage build process

### GitHub Actions Setup

This repository uses GitHub Actions for automated builds and releases. To set up the workflows:

#### Required Secrets

No additional secrets are required! The workflows use GitHub's built-in `GITHUB_TOKEN` secret to authenticate with GitHub Container Registry.

#### Workflows

1. **Build and Test** (`.github/workflows/build.yml`)
   - Runs on every push to main and pull requests
   - Builds the Docker image and runs basic tests
   - Does not push to Docker Hub

2. **Release** (`.github/workflows/release.yml`)
   - Runs every 6 hours to check for new Gluetun releases
   - Automatically builds and releases new versions when Gluetun updates
   - Pushes to GitHub Container Registry (ghcr.io/m2sh/ha-addon-glutun)
   - Supports multiple architectures: amd64, arm64, armv7, armv6
   - Can be triggered manually with a specific Gluetun version

3. **Manual Release** (`.github/workflows/manual-release.yml`)
   - Manual workflow for building specific Gluetun versions
   - Pushes to GitHub Container Registry (ghcr.io/m2sh/ha-addon-glutun)
   - Supports multiple architectures: amd64, arm64, armv7, armv6
   - Useful for testing or building older versions

#### Automatic Release Process

1. The release workflow checks for new Gluetun releases every 6 hours
2. When a new Gluetun version is detected, it:
   - Updates the Dockerfile with the new Gluetun version
   - Builds the Docker image
   - Pushes to GitHub Container Registry with the Gluetun version as the tag
   - Creates a Git tag and GitHub release
   - Also tags as `latest`

#### Manual Release

To manually trigger a release:

1. Go to the **Actions** tab in your GitHub repository
2. Select **Manual Release** workflow
3. Click **Run workflow**
4. Enter the Gluetun version (e.g., `v3.45.0`)
5. Optionally specify a custom Docker tag
6. Click **Run workflow**

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Gluetun](https://github.com/qdm12/gluetun) - The underlying VPN client
- [Home Assistant](https://home-assistant.io/) - The home automation platform
- All VPN providers for their services

## Support

If you encounter any issues:

1. Check the [Gluetun documentation](https://github.com/qdm12/gluetun)
2. Review the addon logs
3. Open an issue on the GitHub repository
4. Ask for help in the Home Assistant community forums 