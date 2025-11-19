#!/bin/bash

echo "======================================"
echo " 🗑️  Uninstalling Node Exporter        "
echo "======================================"

SERVICE="/etc/systemd/system/node_exporter.service"
BINARY="/usr/local/bin/node_exporter"
USER="nodeusr"

echo "1️⃣ Stopping node_exporter service (if running)..."
sudo systemctl stop node_exporter 2>/dev/null || true

echo "2️⃣ Disabling service..."
sudo systemctl disable node_exporter 2>/dev/null || true

echo "3️⃣ Removing systemd service file..."
if [ -f "$SERVICE" ]; then
    sudo rm -f $SERVICE
    echo "✔ Service file removed"
else
    echo "⚠ No service file found"
fi

echo "4️⃣ Removing node_exporter binary..."
if [ -f "$BINARY" ]; then
    sudo rm -f $BINARY
    echo "✔ Binary removed"
else
    echo "⚠ No binary found in /usr/local/bin"
fi

echo "5️⃣ Reloading systemd..."
sudo systemctl daemon-reload

echo "6️⃣ Removing extracted folders..."
sudo rm -rf node_exporter-* 2>/dev/null

echo "7️⃣ Removing user (optional)..."
if id "$USER" >/dev/null 2>&1; then
    sudo userdel $USER
    echo "✔ User removed"
else
    echo "⚠ User does not exist"
fi

echo "8️⃣ Checking if port 9100 is still active..."
if ss -tulnp | grep 9100 >/dev/null; then
    echo "❌ ERROR: Something else is running on port 9100"
else
    echo "✔ Port 9100 free"
fi

echo "======================================"
echo " 🎉 Node Exporter Uninstalled          "
echo "======================================"
