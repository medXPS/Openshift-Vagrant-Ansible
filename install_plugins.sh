#!/bin/bash

# Navigate to home directory and update vagrant plugins
( cd ~ && vagrant plugin update )

# Install necessary plugins
( cd ~ && vagrant plugin install  vagrant-hostmanager landrush vagrant-sshfs vagrant-reload )


#this tool is already added : landrush