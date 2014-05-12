# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

#
# mac specific magic to avoid getting queried
#
#
is_osx=false

if (/darwin/ =~ RUBY_PLATFORM) != nil
  is_osx=true
end

if is_osx
  pref_interface = ['en3: Thunderbolt 1', 'en4: Thunderbolt 2', 'en0: Wi-Fi (AirPort)']
  vm_interfaces = %x( VBoxManage list bridgedifs | grep ^Name ).gsub(/Name:\s+/, '').split("\n")
  pref_interface = pref_interface.map {|n| n if vm_interfaces.include?(n)}.compact
  $network_interface = pref_interface[0]
end

orgName='YOURORG'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "opscode-ubuntu-13.04"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/opscode-ubuntu-13.04.box"

  # set the size of your created VM here by uncommenting and setting param
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  if is_osx
    config.vm.network "public_network", :bridge => $network_interface
  else
    config.vm.network "public_network"
  end

  config.vm.network "private_network", ip: "192.168.56.160".

      filesync = %w(~/.gitconfig ~/.vimrc ~/.screenrc)
  filesync.each do |src|
    config.vm.provision :file do |file|
      file.source = src
      file.destination = src
    end
  end

  config.omnibus.chef_version = :latest
  #   chef.validation_client_name = "ORGNAME-validator"
  config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "https://api.opscode.com/organizations/#{orgName}"
    chef.validation_client_name = "#{orgName}-validator"
    chef.validation_key_path = "#{ENV['HOME']}/.chef/#{orgName}-validator.pem"
    # this creates nat address which is fine for hosted
    # Add a recipe
    #chef.add_recipe "vim"
    #chef.add_recipe "java"
    #chef.add_recipe "jenkins::_master_package"
    chef.node_name = "ubuntu-chef"
    chef.provisioning_path = "/etc/chef"
    chef.log_level = :info
  end
end
