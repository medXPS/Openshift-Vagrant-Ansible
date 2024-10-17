# # -*- mode: ruby -*-
# # vi: set ft=ruby :

# # Vagrant configuration file

# require 'socket'

# hostname = Socket.gethostname
# localmachineip = IPSocket.getaddress(Socket.gethostname)
# puts %Q{ This machine has the IP '#{localmachineip}' and host name '#{hostname}'}

# REQUIRED_PLUGINS = %w(vagrant-hostmanager landrush)
# SUGGESTED_PLUGINS = %w(vagrant-reload)

# def message(name)
#   "#{name} plugin is not installed, run `vagrant plugin install #{name}` to install it."
# end

# errors = []
# REQUIRED_PLUGINS.each { |plugin| errors << message(plugin) unless Vagrant.has_plugin?(plugin) }
# unless errors.empty?
#   msg = errors.size > 1 ? "Errors: \n* #{errors.join("\n* ")}" : "Error: #{errors.first}"
#   raise Vagrant::Errors::VagrantError, msg
# end

# SUGGESTED_PLUGINS.each { |plugin| print("note: " + message(plugin) + "\n") unless Vagrant.has_plugin?(plugin) }

# ### VARIABLES #####
# VAGRANTFILE_API_VERSION = '2'
# NETWORK_BASE = '192.168.100'

# # Start Vagrant Configuration
# Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

#   # Global VirtualBox provider configuration
#   config.vm.provider :virtualbox do |vb|
#     vb.cpus = 2
#     vb.memory = 2048
#   end

#   config.vm.synced_folder ".", "/vagrant", disabled: true
#   config.vm.provision "shell", path: "provision/setup.sh", args: [NETWORK_BASE]

#   # Enable hostmanager plugin to manage hosts
#   config.hostmanager.enabled = true
#   config.hostmanager.manage_host = true
#   config.hostmanager.ignore_private_ip = false

#   # Enable landrush plugin for DNS resolution
#   if Vagrant.has_plugin?('landrush')
#     config.landrush.enabled = true
#     config.landrush.tld = 'adria-bt.com'
#     config.landrush.guest_redirect_dns = false
#   end

#   # Load Balancer node (Optional, runs Ansible playbook)
#   config.vm.define :lb do |node|
#     node.vm.synced_folder "/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible", "/home/vagrant/sync", type: "rsync"
#     node.vm.box = "boxomatic/centos-stream-9"
#     node.vm.network :private_network, ip: "192.168.100.2", nic_type: "virtio", auto_config: true
#     node.vm.hostname = "lb.adria-bt.com"
#     node.hostmanager.aliases = %w(lb)
#     node.vm.provider :virtualbox do |vb|
#       vb.cpus = 2
#       vb.memory = 2048
#     end
#     node.vm.provision "ansible" do |ansible|
#       ansible.playbook = "/home/vagrant/sync/ansible/lb.yml"
#     end

#     if Vagrant.has_plugin?('vagrant-reload')
#       node.vm.provision :reload
#     end
#   end

#   # Bootstrap node
#   config.vm.define :bootstrap do |node|
#     node.vm.box = "boxomatic/centos-stream-9"
#     node.vm.network :private_network, ip: "192.168.100.5", mac: "525400A86405", nic_type: "virtio", auto_config: true
#     node.vm.hostname = "bootstrap.adria-bt.com"
#     node.hostmanager.aliases = %w(bootstrap)
#     node.vm.provider :virtualbox do |vb|
#       vb.memory = 2048
#       vb.cpus = 2
#     end

#     if Vagrant.has_plugin?('vagrant-reload')
#       node.vm.provision :reload
#     end
#   end

#   # Control plane node (master node)
#   config.vm.define :cp0 do |node|
#     node.vm.box = "boxomatic/centos-stream-9"
#     node.vm.network :private_network, ip: "192.168.100.10", mac: "525400A8640A", nic_type: "virtio", auto_config: true
#     node.vm.hostname = "cp0.adria-bt.com"
#     node.hostmanager.aliases = %w(cp0)
#     node.vm.provider :virtualbox do |vb|
#       vb.memory = 2048
#       vb.cpus = 2
#     end

#     if Vagrant.has_plugin?('vagrant-reload')
#       node.vm.provision :reload
#     end
#   end

#   # Worker nodes
#   mac_addresses = [
#     "525400A8640B", # MAC for worker0
#   ]

#   (0..0).each do |node_num|
#     config.vm.define "worker#{node_num}" do |node|
#       node.vm.box = "boxomatic/centos-stream-9"
#       node.vm.network :private_network, ip: "192.168.100.2#{node_num + 1}", mac: mac_addresses[node_num], nic_type: "virtio", auto_config: true
#       node.vm.hostname = "worker#{node_num}.adria-bt.com"
#       node.hostmanager.aliases = %W(worker#{node_num})
#       node.vm.provider :virtualbox do |vb|
#         vb.memory = 2048
#         vb.cpus = 2
#       end

#       if Vagrant.has_plugin?('vagrant-reload')
#         node.vm.provision :reload
#       end
#     end
#   end
# end
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'socket'

hostname = Socket.gethostname
localmachineip = IPSocket.getaddress(Socket.gethostname)
puts %Q{ This machine has the IP '#{localmachineip}' and host name '#{hostname}'}

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

box_name = 'boxomatic/centos-stream-9'

NETWORK_BASE = '192.168.100'  # Adjusted Network for this use case
INTEGRATION_START_SEGMENT = 20

REQUIRED_PLUGINS = %w(vagrant-hostmanager  landrush)
SUGGESTED_PLUGINS = %w(vagrant-reload)

def message(name)
  "#{name} plugin is not installed, run `vagrant plugin install #{name}` to install it."
end

SUGGESTED_PLUGINS.each { |plugin| print("note: " + message(plugin) + "\n") unless Vagrant.has_plugin?(plugin) }

errors = []

# Validate and collect error message if plugin is not installed
REQUIRED_PLUGINS.each { |plugin| errors << message(plugin) unless Vagrant.has_plugin?(plugin) }
unless errors.empty?
  msg = errors.size > 1 ? "Errors: \n* #{errors.join("\n* ")}" : "Error: #{errors.first}"
  fail Vagrant::Errors::VagrantError.new, msg
end

# Helper function to quote labels
def quote_labels(labels)
  if Vagrant::VERSION.to_i >= 2
    return '{' + labels.map{|k, v| "\"#{k}\": \"#{v}\""}.join(', ') + '}'
  else
    return '"{' + labels.map{|k, v| "'#{k}': '#{v}'"}.join(', ') + '}"'
  end
end

# Start Vagrant Configuration
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  # Enable landrush plugin for DNS resolution
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true
    config.landrush.tld = 'adria-bt.com'
    config.landrush.guest_redirect_dns = false
  end

  # Global VirtualBox provider configuration
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = 2048
    vb.cpus = 2
    override.vm.box = box_name
  end

  # Define bootstrap node
  config.vm.define :bootstrap do |node|
    node.vm.box = box_name
    node.vm.network :private_network, ip: "#{NETWORK_BASE}.5"
    node.vm.hostname = "bootstrap.adria-bt.com"
    node.hostmanager.aliases = %w(bootstrap)
    node.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    node.vm.provision "shell", inline: <<-SHELL
    echo "deltarpm_percentage=0" >> /etc/yum.conf
    yum -y update
    # yum install dnsmasq
  SHELL
    if Vagrant.has_plugin?('vagrant-reload')
      node.vm.provision :reload
    end
  end

  # Define Load Balancer node
  config.vm.define :lb do |node|
    node.vm.synced_folder "/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible", "/home/vagrant/sync", type: "rsync"
    node.vm.box = box_name
    node.vm.network :private_network, ip: "#{NETWORK_BASE}.2"
    node.vm.hostname = "lb.adria-bt.com"
    node.hostmanager.aliases = %w(lb)
    node.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    node.vm.provision "shell", inline: <<-SHELL
    echo "deltarpm_percentage=0" >> /etc/yum.conf
    yum -y update
    # yum install dnsmasq
    yum install ansible -y
  SHELL

    # Provision with Ansible playbook
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "/home/vagrant/sync/ansible/lb.yml"
    end

    if Vagrant.has_plugin?('vagrant-reload')
      node.vm.provision :reload
    end
  end

  # Define control plane node (cp0)
  config.vm.define :cp0 do |node|
    node.vm.box = box_name
    node.vm.network :private_network, ip: "#{NETWORK_BASE}.10"
    node.vm.hostname = "cp0.adria-bt.com"
    node.hostmanager.aliases = %w(cp0)
    node.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    node.vm.provision "shell", inline: <<-SHELL
    echo "deltarpm_percentage=0" >> /etc/yum.conf
    yum -y update
    # yum install dnsmasq
  SHELL
    if Vagrant.has_plugin?('vagrant-reload')
      node.vm.provision :reload
    end
  end

  # Define worker nodes
  config.vm.define "worker" do |node|
    node.vm.box = box_name
    node.vm.network :private_network, ip: "#{NETWORK_BASE}.21"
    node.vm.hostname = "worker.adria-bt.com"
    node.hostmanager.aliases = %w(worker)
    node.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    node.vm.provision "shell", inline: <<-SHELL
    echo "deltarpm_percentage=0" >> /etc/yum.conf
    yum -y update
    # yum install dnsmasq
  SHELL

    if Vagrant.has_plugin?('vagrant-reload')
      node.vm.provision :reload
    end
  end
end
