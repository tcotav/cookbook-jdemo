require 'serverspec'
require 'net/ssh'

include Serverspec::Helper::Ssh
include Serverspec::Helper::DetectOS
#include Serverspec::Helper::Properties

#properties = YAML.load_file('properties.yml')

RSpec.configure do |c|
  c.host  = ENV['TARGET_HOST']
  p c.host
#  set_property properties[c.host]
  if c.host == 'localhost'
    options = {
        :port => 2222,
        :user => 'vagrant',
    }
    #options = Net::SSH::Config.for(c.host)
    user = 'vagrant'
  else
    options = Net::SSH::Config.for(c.host)
    user    = options[:user] || Etc.getlogin
  end
  c.ssh   = Net::SSH.start(c.host, user, options)
  c.os    = backend.check_os
end