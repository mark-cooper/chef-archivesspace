#
# Cookbook Name:: chef-archivesspace
# Recipe:: monit
#
# GPL v3 2013 Mark Cooper
# 

package "monit" do
  action :install
end

# apply archivesspace config
template "/etc/monit/conf.d/archivesspace.conf" do
  source "archivesspace.conf.erb"
  owner  'root'
  group  'root'
  mode   "0600"
  variables(
    :embedded => node['archivesspace']['db']['embedded'],
    :http_check_url => node['archivesspace']['proxy']['public_server_names'].split(" ")[0],
    :proxy => node['archivesspace']['proxy']['enabled']
  )
end

execute "monit-start" do
  command "service monit start"
end

execute "monit-reload-configuration" do
  command "monit reload"
end

Chef::Log.info('Enable monit web server if not already configured')
