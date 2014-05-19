#
# Cookbook Name:: jdemo
# Recipe:: default
#
# Copyright (C) 2014 
#
# 
#

include_recipe 'apt'
include_recipe 'tomcat'

# retrieve and untar package
src_url= node['jdemo']['war']['src_url']

service "tomcat" do
  action :nothing
end

# shasum -a 256 punter.war   -- to get checksum
remote_file "punter.war in repo" do
  path "/var/lib/tomcat6/webapps/punter.war"
  owner 'root'
  group 'root'
  mode 0755
  source src_url
  checksum "6753cca87bec143154e8a95b0fcdcdee340352fd8977c15637336aefaa970653"
  action :create_if_missing
  notifies :restart,  resources(:service => "tomcat"), :immediately
end

