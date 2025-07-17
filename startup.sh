#!/bin/sh

# Start the web API in the background
python3 /web/api.py &

# Wait a moment for the API to start
sleep 2

# Start Gluetun (this will be the main process)
exec /gluetun 