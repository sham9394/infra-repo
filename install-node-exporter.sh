#!/bin/bash

echo "================================="
echo " 🚀 Installing Node Exporter     "
echo "================================="

LATEST="1.10.2"
FILE="node_exporter-${LATEST}.linux-amd64"
TAR="${FILE}.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/v${LATEST}/${TAR}"

echo "1️⃣ Creating user nodeusr..."
sudo useradd -rs /bin/false nodeusr 2>/dev/null || true

echo "2️⃣ Downloading node_exporter version ${LATEST}..."
wget -q $URL

if [ ! -f "$TAR" ]; then
  echo "❌ ERROR: Download failed. Check GitHub URL or internet."
  exit 1
fi

echo "3️⃣ Extracting package..."
tar -xzf $TAR

echo "4️⃣ Moving binary to /usr/local/bin..."
sudo mv ${FILE}/node_exporter /usr/local/bin/

echo "5️⃣ Setting correct permissions..."
sudo chown nodeusr:nodeusr /usr/local/bin/node_exporter

echo "6️⃣ Creating systemd service..."
sudo tee /etc/systemd/system/node_exporter.service >/dev/null <<EOF
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=nodeusr
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo "7️⃣ Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo "8️⃣ Checking service status..."
sudo systemctl status node_exporter --no-pager

echo "9️⃣ Testing metrics endpoint..."
sleep 2
curl http://localhost:9100/metrics | head

echo "================================="
echo " 🎉 Node Exporter Installed!     "
echo "================================="
