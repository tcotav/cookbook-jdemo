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

orgName='gnslngr'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.box = "opscode-ubuntu-13.04"
  #config.vm.box_url = "http://files.vagrantup.com/opscode-ubuntu-13.04.box"

  config.vm.box = 'ubuntu-12.04'
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{config.vm.box}_chef-provisionerless.box"

  config.vm.boot_timeout = 300
  #config.berkshelf.enabled = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.define "jdemo01" do |jdemo01|
  end
  config.vm.hostname = "vagrant-jdemo"

  if is_osx
    config.vm.network "public_network", :bridge => $network_interface
  else
    config.vm.network "public_network"
  end

  config.vm.provision "chef_client" do |chef|
    chef.chef_server_url = "https://api.opscode.com/organizations/#{orgName}"
    #chef.validation_client_name = "#{orgName}-validator"
    chef.validation_key_path = "#{ENV['HOME']}/.chef/#{orgName}-validator.pem"
    # this creates nat address which is fine for hosted
    # Add a recipe
    chef.add_recipe "jdemo::default"
    chef.node_name = "ubuntu-chef-jdemo"
    chef.provisioning_path = "/etc/chef"
    chef.log_level = :info
    chef.delete_node = true
    chef.delete_client = true
  end
end
