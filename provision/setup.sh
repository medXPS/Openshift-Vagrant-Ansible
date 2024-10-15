#!/bin/bash

# Capture network variable:
NETWORK_BASE=$1
sudo -i

echo "Check eth1 IP config for netbase: $NETWORK_BASE"

if ip a show dev eth1 | grep -q "inet $NETWORK_BASE"; then
  echo "eth1 IP detected"
else
  echo "eth1 missing IP; restarting interface"
  nmcli device disconnect eth1 && nmcli device connect eth1
fi
