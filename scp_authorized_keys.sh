#!/bin/bash

# Define the WSL directory where SSH keys are stored
WSL_VAGRANT_DIR="/home/devops/openshift/Openshift-Vagrant-Ansible/.vagrant/machines"
# Define the user and host for admin1
ADMIN1_USER="vagrant"
ADMIN1_HOST="192.168.50.23"  # Replace with the actual IP or hostname of admin1
ADMIN1_SSH_DIR="/home/vagrant/.ssh"
VAGRANT_KEY_PATH="/home/devops/openshift/Openshift-Vagrant-Ansible/.vagrant/machines/admin1/virtualbox/private_key"

# Ensure the .ssh directory exists on admin1
ssh -i "$VAGRANT_KEY_PATH" "$ADMIN1_USER@$ADMIN1_HOST" << EOF
  mkdir -p $ADMIN1_SSH_DIR
  chmod 700 $ADMIN1_SSH_DIR
EOF

# Copy public keys from WSL to admin1 VM
for VM in master1 node1 node2; do
    echo "Copying SSH keys from $VM to admin1..."
    
    # Use SCP to copy the private key to admin1 VM
    scp -i "$VAGRANT_KEY_PATH" "$WSL_VAGRANT_DIR/$VM/virtualbox/private_key" \
        "$ADMIN1_USER@$ADMIN1_HOST:/tmp/${VM}_private_key"
    
    # SSH into admin1 and move the keys to the correct directory, setting the right permissions
    ssh -i "$VAGRANT_KEY_PATH" "$ADMIN1_USER@$ADMIN1_HOST" << EOF
      sudo mv /tmp/${VM}_private_key $ADMIN1_SSH_DIR/${VM}_id_rsa
      sudo chmod 600 $ADMIN1_SSH_DIR/${VM}_id_rsa
      sudo chown $ADMIN1_USER:$ADMIN1_USER $ADMIN1_SSH_DIR/${VM}_id_rsa
EOF
    
    echo "Key for $VM copied and permissions set."
done

# Append the public keys to authorized_keys on admin1
echo "Appending keys to authorized_keys on admin1..."
for VM in master1 node1 node2; do
    ssh -i "$VAGRANT_KEY_PATH" "$ADMIN1_USER@$ADMIN1_HOST" "ssh-keyscan $VM.example.com >> $ADMIN1_SSH_DIR/authorized_keys"
done

# Set correct permissions for authorized_keys
ssh -i "$VAGRANT_KEY_PATH" "$ADMIN1_USER@$ADMIN1_HOST" << EOF
  sudo chmod 600 $ADMIN1_SSH_DIR/authorized_keys
  sudo chown $ADMIN1_USER:$ADMIN1_USER $ADMIN1_SSH_DIR/authorized_keys
EOF

echo "Keys copied and configured successfully on admin1."
