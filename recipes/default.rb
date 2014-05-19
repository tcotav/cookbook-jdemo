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



#default['jdemo']['war']['base_source_url']='https://github.com/tcotav/punter/blob/master/'
#default['jdemo']['war']['war_file']='punter.war.0101003?raw=true'

# retrieve and untar package
src_url="#{node['jdemo']['war']['base_src_url']}/#{node['jdemo']['war']['war_file']}"
src_filepath=Chef::Config[:file_cache_path]
src_filename=node['jdemo']['war']['war_file'].split('?')[0]

local_file="#{src_filepath}/#{src_filename}"

## if web browser supports ETag then remote_file is idempotent
## else we'll have to check file/hash
remote_file local_file do
  source src_url
  notifies :stop,  "service tomcat", :immediately
  notifies :create,  "file /var/lib/tomcat6/webapps/punter.war", :immediately
  not_if { ::File.exists? local_file }
end

service "tomcat" do
  action :nothing
end

file "/var/lib/tomcat6/webapps/punter.war"  do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open(local_file).read
  notifies :start,  "service tomcat", :immediately
  action :nothing
end

service "tomcat" do
  action :nothing
end
