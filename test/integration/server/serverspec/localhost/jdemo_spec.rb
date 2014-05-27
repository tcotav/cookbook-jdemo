require 'serverspec'
require 'net/ssh'

include Serverspec::Helper::Ssh
include Serverspec::Helper::DetectOS
#include Serverspec::Helper::Properties

#properties = YAML.load_file('properties.yml')

RSpec.configure do |c|
  c.before do
    host  =  'localhost'
    if c.host != host
      c.ssh.close if c.ssh
      c.host  = host
      options = Net::SSH::Config.for(c.host)
      options[:port] = 2222
      user    = 'vagrant' #options[:user] || Etc.getlogin
      c.ssh   = Net::SSH.start(c.host, user, options)
    end
  end
end


describe package('openjdk-7-jdk') do
  it { should be_installed }
end

describe package('tomcat6') do
  it { should be_installed }
end

describe port(8080) do
  it { should be_listening }
end

describe file('/var/lib/tomcat6/webapps/punter.war') do
  it { should be_file }
end

describe file('/var/lib/tomcat6/webapps/punter') do
  it { should be_directory }
end
