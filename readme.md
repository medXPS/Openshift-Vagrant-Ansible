### Install Openshift  your local pc  using Vagrant and Ansible
|                                                              |
|                                                              |
|______________________________________________________________|


# OpenShift Origin (OKD) Vagrant
This is a Vagrant based project that demonstrates an advanced Openshift Origin 3.10 installation process using an Ansible playbook.

## Notice
This repository has been forked from [openshift/openshift-ansible-contrib](https://github.com/openshift/openshift-ansible-contrib/tree/master/vagrant).
If you want to install OpenShift Container Platform (with a valid RedHat subscription) please use the original repository.

## Prerequisites

### System Requirements
* CPU with at least 4-cores (or virtual cores)
* Minimal 12GB Memory (Each VM uses 2GB memory)

__Each VM requires at least 2GB memory.__<br>
Reducing the memory settings will result in installation fail (the ansible installer fails for random reasons).
Nevertheless, it is possible and recommended to increase the memory settings to 4GB when there is sufficient memory installed.

### Software Requirements
* Vagrant
* VirtualBox or Libvirt (--provider=libvirt)

### Vagrant Plugins
* landrush
* vagrant-hostmanager
* vagrant-sshfs
* vagrant-reload (optional)

There is a shell script available to install all vagrant plugins:
```bash
./install_plugins.sh
```

### Additional Information
The project uses the [CentOS](https://app.vagrantup.com/centos/boxes/7) base box as underlying operating system. You can change the vagrant box by changing "box_name" variable in Vagrantfile.
Be aware that OpenShift only works properly with RHEL, CentOS or Fedora based distributions.



## Installation

```bash
vagrant up
```

Four ansible playbooks will start on admin1 after it has booted.
The first playbook bootstraps the prerequisites for OpenShift.
After that the OpenShift installer - consisting of two playbooks - are run according to the [Origin documentation](https://docs.okd.io/3.10/install/running_install.html).
Finally a post-installation playbook is run which grants the "cluster-admin" role to the admin user.

The install comprises one master and two nodes. The NFS share gets created on admin1.

### Technology Preview: CRI-O
To enable the cri-o container runtime which is currently in technology preview use:
```bash
# Install CRI-O along with docker runtime
export OKD_ENABLE_CRIO=1
vagrant up
# or
OKD_ENABLE_CRIO=1 vagrant up
```



## Login to your cluster

```bash
oc login https://master1.example.com:8443 -u admin -p admin123
```

Login to the web console on https://master1.example.com:8443 with user "admin" and password "admin123".


## Troubleshooting
The landrush plugin creates a small DNS server to that the guest VMs can resolve each others hostnames and also the host can resolve the guest VMs hostnames.
The landrush DNS server is listens on 127.0.0.1 on port 10053. It uses a dnsmasq process to redirect dns traffic to landrush. If this isn't working verify that:

    cat /etc/dnsmasq.d/vagrant-landrush

gives

    server=/example.com/127.0.0.1#10053

and that /etc/resolv.conf has an entry
    # Added by landrush, a vagrant plugin
    nameserver 127.0.0.1



```
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"


```


```
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


```


```
+++
export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="/mnt/c/Users/mamma/Documents/Openshift-Vagrant-Ansible"
+++


```
sudo sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS-*.repo
sudo sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS-*.repo
 sudo sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS-*.repo

```

sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*