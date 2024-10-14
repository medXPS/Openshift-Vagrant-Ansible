# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'socket'

# Retrieve and display the hostname and IP address of the local machine
hostname = Socket.gethostname
local_machine_ip = IPSocket.getaddress(hostname)
puts "This machine has the IP '#{local_machine_ip}' and hostname '#{hostname}'"

# Vagrantfile API/syntax version. Do not modify unless you are certain.
VAGRANTFILE_API_VERSION = '2'

# Flag to indicate if WSL (Windows Subsystem for Linux) is being used
IS_WSL_USED = true

# Deployment configuration
deployment_type = 'origin'
box_name = 'centos/8'
crio_env = ENV['OKD_ENABLE_CRIO'] || false

# Determine whether to enable CRI-O based on environment variable
enable_crio = %w[1 true on].include?(crio_env.to_s.downcase)

# Define required and suggested Vagrant plugins
REQUIRED_PLUGINS = %w[vagrant-hostmanager vagrant-sshfs landrush vagrant-bindfs]
SUGGESTED_PLUGINS = %w[vagrant-reload]

# Helper method to generate plugin installation messages
def plugin_message(name)
  "#{name} plugin is not installed. Run `vagrant plugin install #{name}` to install it."
end

# Notify about missing suggested plugins
SUGGESTED_PLUGINS.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    puts "Note: #{plugin_message(plugin)}"
  end
end

# Collect errors for missing required plugins
errors = REQUIRED_PLUGINS.reject { |plugin| Vagrant.has_plugin?(plugin) }.map { |plugin| plugin_message(plugin) }

# Raise an error if any required plugins are missing
unless errors.empty?
  msg = errors.size > 1 ? "Errors:\n* #{errors.join("\n* ")}" : "Error: #{errors.first}"
  fail Vagrant::Errors::VagrantError.new, msg
end

# Network configuration
NETWORK_BASE = '192.168.50'
INTEGRATION_START_SEGMENT = 20

# Method to quote labels based on Vagrant version
def quote_labels(labels)
  if Vagrant::VERSION.to_i >= 2
    '{' + labels.map { |k, v| "\"#{k}\": \"#{v}\"" }.join(', ') + '}'
  else
    '"{' + labels.map { |k, v| "'#{k}': '#{v}'" }.join(', ') + '}"'
  end
end

# Configure Vagrant
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Hostmanager configuration
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  # Landrush configuration if the plugin is available
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true
    config.landrush.tld = 'example.com'
    config.landrush.guest_redirect_dns = false
  end

  # Provisioning script to configure eth0
  config.vm.provision "shell", path: "provision/setup.sh", args: [NETWORK_BASE]

  # VirtualBox provider configuration
  config.vm.provider "virtualbox" do |v, override|
    v.memory = 2048
    v.cpus = 1
    override.vm.box = box_name
    @provider_name = 'virtualbox'
  end

  # Libvirt provider configuration
  config.vm.provider "libvirt" do |libvirt, override|
    libvirt.cpus = 1
    libvirt.memory = 2048
    libvirt.driver = 'kvm'
    override.vm.box = box_name
    @provider_name = 'libvirt'
  end

  # Bindfs configuration for shared folders
  config.bindfs.bind_folder '//wsl.localhost/Ubuntu/home/devops/openshift/Openshift-Vagrant-Ansible', '/home/vagrant/sync',
                             owner: "vagrant",
                             group: "vagrant",
                             perms: "0775",
                             chown_ignore: true,
                             chgrp_ignore: true,
                             chmod_ignore: true

  config.bindfs.bind_folder '//wsl.localhost/Ubuntu/home/devops/openshift/Openshift-Vagrant-Ansible/.vagrant', '/home/vagrant/.hidden',
                             owner: "vagrant",
                             group: "vagrant",
                             perms: "0600",
                             chown_ignore: true,
                             chgrp_ignore: true,
                             chmod_ignore: true

  # Define the master node
  config.vm.define "master1" do |master1|
    master1.vm.network :private_network, ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT}"
    master1.vm.hostname = "master1.example.com"
    master1.hostmanager.aliases = %w[master1]

    # Provisioning to update the VM and install necessary packages
    master1.vm.provision "shell", inline: <<-SHELL
      echo "deltarpm_percentage=0" >> /etc/yum.conf
      yum -y update
      yum -y install python38 python38-pip
    SHELL

    # Reboot the machine if vagrant-reload plugin is available
    master1.vm.provision :reload if Vagrant.has_plugin?('vagrant-reload')
  end

  # Define node1
  config.vm.define "node1" do |node1|
    node1.vm.network :private_network, ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + 1}"
    node1.vm.hostname = "node1.example.com"
    node1.hostmanager.aliases = %w[node1]

    node1.vm.provision "shell", inline: <<-SHELL
      echo "deltarpm_percentage=0" >> /etc/yum.conf
      yum -y update
      yum -y install python38 python38-pip
    SHELL

    node1.vm.provision :reload if Vagrant.has_plugin?('vagrant-reload')
  end

  # Define node2
  config.vm.define "node2" do |node2|
    node2.vm.network :private_network, ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + 2}"
    node2.vm.hostname = "node2.example.com"
    node2.hostmanager.aliases = %w[node2]

    node2.vm.provision "shell", inline: <<-SHELL
      echo "deltarpm_percentage=0" >> /etc/yum.conf
      yum -y update
      yum -y install python38 python38-pip
    SHELL

    node2.vm.provision :reload if Vagrant.has_plugin?('vagrant-reload')
  end

  # Define admin1
  config.vm.define "admin1" do |admin1|
    admin1.vm.network :private_network, ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + 3}"
    admin1.vm.hostname = "admin1.example.com"
    admin1.hostmanager.aliases = %w[admin1]

    # Bindfs configuration specific to admin1
    if IS_WSL_USED
      admin1.bindfs.bind_folder '/home/devops/openshift/Openshift-Vagrant-Ansible', '/home/vagrant/sync',
                                 owner: "vagrant",
                                 group: "vagrant",
                                 perms: "0775",
                                 chown_ignore: true,
                                 chgrp_ignore: true,
                                 chmod_ignore: true

      admin1.bindfs.bind_folder '/home/devops/openshift/Openshift-Vagrant-Ansible/.vagrant', '/home/vagrant/.hidden',
                            
                                 owner: "vagrant",
                                 group: "vagrant",
                                 perms: "0775",
                                 chown_ignore: true,
                                 chgrp_ignore: true,
                                 chmod_ignore: true

      admin1.bindfs.bind_folder '/home/devops/openshift/Openshift-Vagrant-Ansible/.vagrant/machines', '/home/vagrant/sync/.vagrant/machines',
                              
                                 owner: "vagrant",
                                 group: "vagrant",
                                 perms: "0600",
                                 chown_ignore: true,
                                 chgrp_ignore: true,
                                 chmod_ignore: true
    end

    # Provisioning to update the VM, install packages, and Ansible
    admin1.vm.provision "shell", inline: <<-SHELL
      echo "deltarpm_percentage=0" >> /etc/yum.conf
      yum -y update
      yum -y install python38 python38-pip
      pip3.8 install --upgrade pip
      pip3.8 install ansible==2.9.27 pyOpenSSL
    SHELL

    # Reboot the machine if vagrant-reload plugin is available
    admin1.vm.provision :reload if Vagrant.has_plugin?('vagrant-reload')

    # Define Ansible group variables
    ansible_groups = {
      OSEv3: ["master1", "node1", "node2"],
      'OSEv3:children': ["masters", "nodes", "etcd", "nfs"],
      'OSEv3:vars': {
        ansible_become: true,
        ansible_ssh_user: 'vagrant',
        deployment_type: deployment_type,
        openshift_deployment_type: deployment_type,
        openshift_release: 'v3.10',
        openshift_clock_enabled: true,
        os_firewall_use_firewalld: true,
        ansible_service_broker_install: false,
        template_service_broker_install: false,
        openshift_master_identity_providers: "[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'file': '/etc/origin/master/htpasswd'}]",
        openshift_master_htpasswd_users: "{'admin': '$apr1$nWG7vwhy$jCMCBmBrW3MEYmCFCckYk1'}",
        openshift_master_default_subdomain: 'apps.example.com',
        openshift_disable_check: "docker_storage,memory_availability,package_version",
        openshift_hosted_registry_replicas: 1,
        openshift_hosted_router_selector: 'node-role.kubernetes.io/master=true',
        openshift_hosted_registry_selector: 'node-role.kubernetes.io/master=true',
        openshift_enable_unsupported_configurations: true, # Needed for NFS registry
        openshift_hosted_registry_storage_kind: 'nfs',
        openshift_hosted_registry_storage_access_modes: ['ReadWriteMany'],
        openshift_hosted_registry_storage_host: 'admin1.example.com',
        openshift_hosted_registry_storage_nfs_directory: '/srv/nfs',
        openshift_hosted_registry_storage_volume_name: 'registry',
        openshift_hosted_registry_storage_volume_size: '2Gi',
        openshift_use_crio: enable_crio
      },
      etcd: ["master1"],
      nfs: ["admin1"],
      masters: ["master1"],
      nodes: ["master1", "node1", "node2"],
    }

    # Define Ansible host variables with updated SSH configurations
    ansible_host_vars = {
      master1: {
        openshift_ip: '192.168.50.20',
        openshift_schedulable: true,
        ansible_host: '127.0.0.1',
        ansible_port: 2222,  # Replace with the actual port from `vagrant ssh-config`
        openshift_node_group_name: "node-config-master"
      },
      node1: {
        openshift_ip: '192.168.50.21',
        openshift_schedulable: true,
        ansible_host: '127.0.0.1',
        ansible_port: 2200,  # Replace with the actual port
        openshift_node_group_name: "node-config-compute"
      },
      node2: {
        openshift_ip: '192.168.50.22',
        openshift_schedulable: true,
        ansible_host: '127.0.0.1',
        ansible_port: 2201,  # Replace with the actual port
        openshift_node_group_name: "node-config-compute"
      },
      admin1: {
        ansible_connection: 'local',
        deployment_type: deployment_type
      }
    }

    #-------------------issue fix 

    # Previously defined ansible_host_vars (commented out) can be removed or kept as a reference
    # ansible_host_vars = {
    #   master1:  {
    #     openshift_ip: '192.168.50.20',
    #     openshift_schedulable: true,
    #     ansible_host: '192.168.50.20',
    #     ansible_ssh_private_key_file: "/home/vagrant/.ssh/master1.key",
    #     openshift_node_group_name: "node-config-master"
    #   },
    #   node1: {
    #     openshift_ip: '192.168.50.21',
    #     openshift_schedulable: true,
    #     ansible_host: '192.168.50.21',
    #     ansible_ssh_private_key_file: "/home/vagrant/.ssh/node1.key",
    #     openshift_node_group_name: "node-config-compute"
    #   },
    #   node2: {
    #     openshift_ip: '192.168.50.22',
    #     openshift_schedulable: true,
    #     ansible_host: '192.168.50.22',
    #     ansible_ssh_private_key_file: "/home/vagrant/.ssh/node2.key",
    #     openshift_node_group_name: "node-config-compute"
    #   },
    #   admin1: {
    #     ansible_connection: 'local',
    #     deployment_type: deployment_type
    #   }
    # }

    # Ansible Local Provisioning Steps
    %w[
      install.yaml
      prerequisites.yml
      deploy_cluster.yml
      post-install.yaml
    ].each do |playbook|
      admin1.vm.provision :ansible_local do |ansible|
        ansible.verbose = true
        ansible.install = (playbook == 'install.yaml') # Only install Ansible for the first playbook
        ansible.limit = "OSEv3:localhost"
        ansible.provisioning_path = '/home/vagrant/sync'
        
        # Determine the correct playbook path based on the playbook name
        case playbook
        when 'install.yaml'
          ansible.playbook = "/home/vagrant/sync/install.yaml"
        when 'post-install.yaml'
          ansible.playbook = "/home/vagrant/sync/tasks/post-install.yaml"
        else
          ansible.playbook = "/home/vagrant/openshift-ansible/playbooks/#{playbook}"
        end

        ansible.groups = ansible_groups
        ansible.host_vars = ansible_host_vars
      end
    end
  end
end
