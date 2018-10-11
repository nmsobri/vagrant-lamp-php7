# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/bionic64"

  # Forward ports to Apache, MySQL, MailCatcher
  config.vm.network "private_network", ip: "10.10.10.10"
  config.vm.synced_folder "www", "/var/www/html", create: true
  config.vm.synced_folder "cachegrind", "/vagrant/cachegrind", create: true
  
  config.vm.provision "shell", path: "provision.sh"

  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
end
