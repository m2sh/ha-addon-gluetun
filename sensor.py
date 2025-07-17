#!/usr/bin/env python3
"""
Home Assistant Sensor for Gluetun VPN Status
"""

import asyncio
import json
import logging
import time
from datetime import datetime, timedelta
import aiohttp
import voluptuous as vol

import homeassistant.helpers.config_validation as cv
from homeassistant.components.sensor import PLATFORM_SCHEMA
from homeassistant.const import (
    CONF_NAME,
    CONF_HOST,
    CONF_PORT,
    ATTR_ATTRIBUTION,
    STATE_UNKNOWN,
)
from homeassistant.helpers.entity import Entity
from homeassistant.helpers.aiohttp_client import async_get_clientsession

_LOGGER = logging.getLogger(__name__)

CONF_UPDATE_INTERVAL = "update_interval"

DEFAULT_NAME = "Gluetun VPN"
DEFAULT_HOST = "localhost"
DEFAULT_PORT = 8000
DEFAULT_UPDATE_INTERVAL = 30

PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend(
    {
        vol.Optional(CONF_NAME, default=DEFAULT_NAME): cv.string,
        vol.Optional(CONF_HOST, default=DEFAULT_HOST): cv.string,
        vol.Optional(CONF_PORT, default=DEFAULT_PORT): cv.port,
        vol.Optional(CONF_UPDATE_INTERVAL, default=DEFAULT_UPDATE_INTERVAL): cv.positive_int,
    }
)

async def async_setup_platform(hass, config, async_add_entities, discovery_info=None):
    """Set up the Gluetun VPN sensor platform."""
    name = config.get(CONF_NAME)
    host = config.get(CONF_HOST)
    port = config.get(CONF_PORT)
    update_interval = config.get(CONF_UPDATE_INTERVAL)

    async_add_entities([GluetunSensor(name, host, port, update_interval)], True)


class GluetunSensor(Entity):
    """Representation of a Gluetun VPN sensor."""

    def __init__(self, name, host, port, update_interval):
        """Initialize the sensor."""
        self._name = name
        self._host = host
        self._port = port
        self._update_interval = update_interval
        self._state = STATE_UNKNOWN
        self._attributes = {}
        self._available = False

    @property
    def name(self):
        """Return the name of the sensor."""
        return self._name

    @property
    def state(self):
        """Return the state of the sensor."""
        return self._state

    @property
    def available(self):
        """Return True if entity is available."""
        return self._available

    @property
    def extra_state_attributes(self):
        """Return the state attributes."""
        return self._attributes

    async def async_update(self):
        """Update the sensor."""
        try:
            session = async_get_clientsession(self.hass)
            async with session.get(
                f"http://{self._host}:{self._port}/v1/openvpn/status",
                timeout=10
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    
                    # Update state
                    if data.get("status") == "connected":
                        self._state = "Connected"
                        self._available = True
                    else:
                        self._state = "Disconnected"
                        self._available = True
                    
                    # Update attributes
                    self._attributes = {
                        "server": data.get("server", "Unknown"),
                        "public_ip": data.get("public_ip", "Unknown"),
                        "uptime": data.get("uptime", "Unknown"),
                        "provider": data.get("provider", "Unknown"),
                        "last_update": datetime.now().isoformat(),
                    }
                    
                    # Try to get additional info
                    try:
                        async with session.get(
                            f"http://{self._host}:{self._port}/v1/status",
                            timeout=5
                        ) as status_response:
                            if status_response.status == 200:
                                status_data = await status_response.json()
                                self._attributes.update({
                                    "version": status_data.get("version", "Unknown"),
                                    "vpn_type": status_data.get("vpn_type", "Unknown"),
                                })
                    except:
                        pass
                        
                else:
                    self._state = "Error"
                    self._available = False
                    self._attributes = {
                        "error": f"HTTP {response.status}",
                        "last_update": datetime.now().isoformat(),
                    }
                    
        except asyncio.TimeoutError:
            self._state = "Timeout"
            self._available = False
            self._attributes = {
                "error": "Connection timeout",
                "last_update": datetime.now().isoformat(),
            }
        except Exception as e:
            self._state = "Error"
            self._available = False
            self._attributes = {
                "error": str(e),
                "last_update": datetime.now().isoformat(),
            }
            _LOGGER.error("Error updating Gluetun sensor: %s", e) 