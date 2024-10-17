# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant configuration file

Vagrant.configure("2") do |config|
  # Global VirtualBox provider configuration
  config.vm.provider :virtualbox do |vb|
    vb.cpus = 2
    vb.memory = 2048
  end

  # Disable synced folder
  config.vm.synced_folder "/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible", "/home/vagrant/sync", type: "rsync"

  # Enable hostmanager plugin to manage hosts
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  # Enable landrush plugin for DNS resolution
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true
    config.landrush.tld = 'adria-bt.com'
    config.landrush.guest_redirect_dns = false
  end

  # Load Balancer node (Optional, runs Ansible playbook)
  config.vm.define :lb, autostart: false do |node|
    node.vm.box = "boxomatic/centos-stream-9"
    node.vm.network :private_network, ip: "192.168.100.2"
    node.vm.hostname = "lb.adria-bt.com"
    node.hostmanager.aliases = %w(lb)
    node.vm.provider :virtualbox do |vb|
      vb.cpus = 2
      vb.memory = 2048
    end
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "/home/vagrant/sync/ansible/lb.yml"
    end
  end

  # Bootstrap node
  config.vm.define :bootstrap do |node|
    node.vm.box = "boxomatic/centos-stream-9"
    node.vm.network :private_network, ip: "192.168.100.5", mac: "525400A86405"
    node.vm.hostname = "bootstrap.adria-bt.com"
    node.hostmanager.aliases = %w(bootstrap)
    node.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
  end

  # Control plane node (master node)
  config.vm.define :cp0 do |node|
    node.vm.box = "boxomatic/centos-stream-9"
    node.vm.network :private_network, ip: "192.168.100.10", mac: "525400A8640A"
    node.vm.hostname = "cp0.adria-bt.com"
    node.hostmanager.aliases = %w(cp0)
    node.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
  end

  # Worker nodes
  mac_addresses = [
    "525400A8640B", # MAC for worker0
  ]

  (0..0).each do |node_num|
    config.vm.define "worker#{node_num}" do |node|
      node.vm.box = "boxomatic/centos-stream-9"
      node.vm.network :private_network, ip: "192.168.100.2#{node_num + 1}", mac: mac_addresses[node_num]
      node.vm.hostname = "worker#{node_num}.adria-bt.com"
      node.hostmanager.aliases = %W(worker#{node_num})
      node.vm.provider :virtualbox do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
    end
  end
end
