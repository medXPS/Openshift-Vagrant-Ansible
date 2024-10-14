#!/bin/bash

# Define the user and the hostnames/ports from your Vagrant SSH config
ADMIN1_HOST="admin1"
ADMIN1_SSH_DIR="/home/vagrant/.ssh"

# Ensure the .ssh directory exists on admin1
ssh admin1 << EOF
  mkdir -p $ADMIN1_SSH_DIR
  chmod 700 $ADMIN1_SSH_DIR
EOF

# Copy public keys from master1, node1, and node2 to admin1 VM
for VM in master1 node1 node2; do
    echo "Copying SSH keys from $VM to admin1..."
    
    # Use SCP to copy the private key to admin1 VM
    scp -F vagrant_ssh_config $VM:/home/vagrant/.ssh/id_rsa.pub /tmp/${VM}_id_rsa.pub
    
    # SSH into admin1 and append the keys to the correct directory, setting the right permissions
    ssh -F vagrant_ssh_config admin1 << EOF
      cat /tmp/${VM}_id_rsa.pub >> $ADMIN1_SSH_DIR/authorized_keys
      rm -f /tmp/${VM}_id_rsa.pub
      chmod 600 $ADMIN1_SSH_DIR/authorized_keys
      chown vagrant:vagrant $ADMIN1_SSH_DIR/authorized_keys
EOF
    
    echo "Key for $VM copied and appended to authorized_keys on admin1."
done

echo "Keys copied and configured successfully on admin1."
