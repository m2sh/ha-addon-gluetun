#!/bin/bash

# Test script for Gluetun Home Assistant Addon

echo "Testing Gluetun Home Assistant Addon..."

# Check if required files exist
echo "Checking required files..."
files=("config.yaml" "build.yaml" "Dockerfile" "run.sh" "startup.sh" "gluetun-config.sh" "web/index.html" "web/api.py" "requirements.txt" "config.schema.json" "README.md")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Check if web directory structure is correct
echo "Checking web directory structure..."
if [ -d "web" ]; then
    echo "✓ web directory exists"
    if [ -f "web/index.html" ]; then
        echo "✓ web/index.html exists"
    else
        echo "✗ web/index.html missing"
        exit 1
    fi
    if [ -f "web/api.py" ]; then
        echo "✓ web/api.py exists"
    else
        echo "✗ web/api.py missing"
        exit 1
    fi
else
    echo "✗ web directory missing"
    exit 1
fi

# Check if configuration schema is valid JSON
echo "Checking configuration schema..."
if python3 -m json.tool config.schema.json > /dev/null 2>&1; then
    echo "✓ config.schema.json is valid JSON"
else
    echo "✗ config.schema.json is not valid JSON"
    exit 1
fi

# Check if Dockerfile syntax is correct
echo "Checking Dockerfile..."
if [ -f "Dockerfile" ]; then
    echo "✓ Dockerfile exists"
    # Basic syntax check
    if grep -q "FROM" Dockerfile && grep -q "CMD" Dockerfile; then
        echo "✓ Dockerfile has basic structure"
    else
        echo "✗ Dockerfile missing basic structure"
        exit 1
    fi
else
    echo "✗ Dockerfile missing"
    exit 1
fi

echo "All tests passed! The addon structure looks correct."
echo ""
echo "To build and test the addon:"
echo "1. docker build -t gluetun-addon ."
echo "2. docker run -p 8888:8888 -p 8388:8388 gluetun-addon" 