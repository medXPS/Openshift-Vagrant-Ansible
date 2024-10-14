# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'socket'

# Retrieve and display the hostname and IP address of the local machine
hostname = Socket.gethostname
localmachineip = IPSocket.getaddress(hostname)
puts %Q{This machine has the IP '#{localmachineip}' and host name '#{hostname}'}

# Vagrantfile API/syntax version
VAGRANTFILE_API_VERSION = '2'
IS_WSL_USED = true

# Deployment configuration
deployment_type = 'origin'
box_name = 'centos/8'
crio_env = ENV['OKD_ENABLE_CRIO'] || false
enable_crio = %w[1 true on].include?(crio_env.to_s.downcase)

# Required and suggested plugins
REQUIRED_PLUGINS = %w[vagrant-hostmanager vagrant-sshfs landrush]
SUGGESTED_PLUGINS = %w[vagrant-reload]

# Helper to output plugin install messages
def plugin_message(name)
  "#{name} plugin is not installed, run `vagrant plugin install #{name}` to install it."
end

# Notify about suggested plugins
SUGGESTED_PLUGINS.each { |plugin| puts "Note: #{plugin_message(plugin)}" unless Vagrant.has_plugin?(plugin) }

# Validate and check for required plugins
errors = REQUIRED_PLUGINS.reject { |plugin| Vagrant.has_plugin?(plugin) }.map { |plugin| plugin_message(plugin) }
unless errors.empty?
  fail Vagrant::Errors::VagrantError, errors.join("\n")
end

# Network configuration
NETWORK_BASE = '192.168.50'
INTEGRATION_START_SEGMENT = 20

# Function to handle version-specific label quoting
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

  # Landrush DNS configuration
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true
    config.landrush.tld = 'example.com'
    config.landrush.guest_redirect_dns = false
  end

  # Shell provisioning for network configuration
  config.vm.provision "shell", path: "provision/setup.sh", args: [NETWORK_BASE]

  # Configure providers
  config.vm.provider "virtualbox" do |v, override|
    v.memory = 2048
    v.cpus = 1
    override.vm.box = box_name
  end

  config.vm.provider "libvirt" do |libvirt, override|
    libvirt.memory = 2048
    libvirt.cpus = 1
    libvirt.driver = 'kvm'
    override.vm.box = box_name
  end

  # Sync folders depending on WSL usage
  if IS_WSL_USED
    config.vm.synced_folder '/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible', '/home/vagrant/sync', type: "rsync"
    config.vm.synced_folder '/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible/.vagrant', '/home/vagrant/.hidden', type: "rsync"
  else
    config.vm.synced_folder '.', '/vagrant', disabled: true
  end

  # VM Definitions: master1, node1, node2, and admin1
  %w[master1 node1 node2].each_with_index do |name, index|
    config.vm.define name do |node|
      node.vm.network :private_network, ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + index}"
      node.vm.hostname = "#{name}.example.com"
      node.hostmanager.aliases = [name]

      node.vm.provision "shell", inline: <<-SHELL
        echo "deltarpm_percentage=0" >> /etc/yum.conf
        yum -y update
        yum -y install python38 python38-pip
      SHELL

      node.vm.provision :reload if Vagrant.has_plugin?('vagrant-reload')
    end
  end

  # Admin1 VM Configuration
  config.vm.define "admin1" do |admin1|
    admin1.vm.network :private_network, ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + 3}"
    admin1.vm.hostname = "admin1.example.com"
    admin1.hostmanager.aliases = %w[admin1]

    # SSH Sync (Modify paths accordingly)
    config.vm.synced_folder '/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible', '/home/vagrant/sync', type: "rsync"
    config.vm.synced_folder '/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible/.vagrant', '/home/vagrant/.hidden', type: "rsync"

    # Provision admin1 to install required software
    admin1.vm.provision "shell", inline: <<-SHELL
      echo "deltarpm_percentage=0" >> /etc/yum.conf
      yum -y update
      yum -y install python38 python38-pip
      pip3.8 install --upgrade pip
      pip3.8 install ansible==2.9.27 pyOpenSSL
    SHELL

    # Reload admin1 if vagrant-reload plugin is available
    admin1.vm.provision :reload if Vagrant.has_plugin?('vagrant-reload')

    # Sync SSH keys from other VMs (master1, node1, node2) to admin1
    %w[master1 node1 node2].each do |vm_name|
      admin1.vm.provision "shell", inline: <<-SHELL
        ssh-keyscan #{vm_name}.example.com >> /home/vagrant/.ssh/known_hosts
        cat /vagrant/#{vm_name}_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
        chmod 600 /home/vagrant/.ssh/authorized_keys
      SHELL
    end

    # Ansible provisioning for admin1
    ansible_groups = {
      OSEv3: ["master1", "node1", "node2"],
      'OSEv3:children': ["masters", "nodes", "etcd", "nfs"],
      'OSEv3:vars': {
        ansible_become: true,
        ansible_ssh_user: 'vagrant',
        deployment_type: deployment_type,
        openshift_deployment_type: deployment_type,
        openshift_release: 'v3.10',
        os_firewall_use_firewalld: true,
        openshift_disable_check: "docker_storage,memory_availability,package_version",
        openshift_use_crio: enable_crio
      },
      etcd: ["master1"],
      nfs: ["admin1"],
      masters: ["master1"],
      nodes: ["master1", "node1", "node2"]
    }

    admin1.vm.provision :ansible_local do |ansible|
      ansible.playbook = '/home/vagrant/sync/install.yaml'
      ansible.groups = ansible_groups
      ansible.host_vars = {
        master1: { openshift_ip: '192.168.50.20', ansible_host: '127.0.0.1', ansible_port: 2222 },
        node1: { openshift_ip: '192.168.50.21', ansible_host: '127.0.0.1', ansible_port: 2200 },
        node2: { openshift_ip: '192.168.50.22', ansible_host: '127.0.0.1', ansible_port: 2201 },
        admin1: { ansible_connection: 'local', deployment_type: deployment_type }
      }
    end
  end
end
