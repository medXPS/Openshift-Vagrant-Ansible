# #!/bin/bash

# # Capture network variable:
# NETWORK_BASE=$1
# sudo -i

# echo "Check eth1 IP config for netbase: $NETWORK_BASE"

# if ip a show dev eth1 | grep -q "inet $NETWORK_BASE"; then
#   echo "eth1 IP detected"
# else
#   echo "eth1 missing IP; restarting interface"
#   nmcli device disconnect eth1 && nmcli device connect eth1
# fi
#!/bin/bash

# Capture network variable:
NETWORK_BASE=$1

echo "Check eth1 IP config for netbase: $NETWORK_BASE"

# Check if eth1 exists
if ! ip link show eth1 > /dev/null 2>&1; then
  echo "eth1 does not exist; unable to configure"
  exit 1
fi

# Restart eth1 interface using nmcli
if ip a show dev eth1 | grep -q "inet $NETWORK_BASE"; then
  echo "eth1 IP detected"
else
  echo "eth1 missing IP; restarting interface with nmcli"
  sudo nmcli device disconnect eth1
  sudo nmcli device connect eth1

  # If it still fails, try to bring the connection up manually
  echo "Attempting to manually bring up the eth1 interface"
  sudo nmcli connection up eth1
fi
