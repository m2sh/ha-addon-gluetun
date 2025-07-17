#!/usr/bin/env python3
"""
API endpoints for Gluetun Home Assistant Addon
"""

import json
import os
import subprocess
import time
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

CONFIG_FILE = "/data/options.json"
STATUS_FILE = "/tmp/gluetun_status.json"

def load_config():
    """Load configuration from Home Assistant options"""
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

def save_config(config):
    """Save configuration to Home Assistant options"""
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)

def get_gluetun_status():
    """Get Gluetun status from API"""
    try:
        response = requests.get('http://localhost:8000/v1/openvpn/status', timeout=5)
        if response.status_code == 200:
            return response.json()
    except:
        pass
    
    # Fallback: check if gluetun process is running
    try:
        result = subprocess.run(['pgrep', 'gluetun'], capture_output=True, text=True)
        return {
            'connected': result.returncode == 0,
            'server': 'Unknown',
            'uptime': 'Unknown',
            'public_ip': 'Unknown'
        }
    except:
        return {
            'connected': False,
            'server': 'Unknown',
            'uptime': 'Unknown',
            'public_ip': 'Unknown'
        }

@app.route('/api/config', methods=['GET'])
def get_config():
    """Get current configuration"""
    config = load_config()
    return jsonify(config)

@app.route('/api/config', methods=['POST'])
def set_config():
    """Set configuration"""
    try:
        config = request.get_json()
        save_config(config)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/status', methods=['GET'])
def get_status():
    """Get Gluetun status"""
    status = get_gluetun_status()
    return jsonify(status)

@app.route('/api/restart', methods=['POST'])
def restart_gluetun():
    """Restart Gluetun service"""
    try:
        # Send restart signal to gluetun
        subprocess.run(['pkill', '-TERM', 'gluetun'])
        time.sleep(2)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888, debug=False) 