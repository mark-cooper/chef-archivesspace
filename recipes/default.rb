#
# Cookbook Name:: chef-archivesspace
# Recipe:: default
#
# GPL v3 2013 Mark Cooper
# 

include_recipe "git"
include_recipe "java"
include_recipe "mysql::client"
include_recipe "mysql::ruby"
include_recipe "unzip"

aspace_path = node['archivesspace']['directory']
db          = nil # will pickup value if mysql enabled

group node["archivesspace"]["user"]["group"] do
  action :create
end

user node["archivesspace"]["user"]["name"] do
  supports :manage_home => true
  home     node["archivesspace"]["user"]["home"]
  group    node["archivesspace"]["user"]["group"]
  shell    "/bin/bash" 
  action   :create
end

directory node['archivesspace']['user']['backups'] do
  owner node["archivesspace"]["user"]["name"]
  group node["archivesspace"]["user"]["group"]
  mode "0755"
  action :create
end

remote_file "#{node["archivesspace"]["user"]["home"]}/archivesspace-v#{node["archivesspace"]["version"]}.zip" do
  source "#{node["archivesspace"]["url"]}/v#{node["archivesspace"]["version"]}/archivesspace-v#{node["archivesspace"]["version"]}.zip"
  mode "0644"
  action :create_if_missing
end

execute "unzip-archivesspace" do
  cwd node["archivesspace"]["user"]["home"]
  command "unzip -o #{node["archivesspace"]["user"]["home"]}/archivesspace-v#{node["archivesspace"]["version"]}.zip -d ."
end

execute "set-archivesspace-runuser" do
  command "sed -i 's/ARCHIVESSPACE_USER=/ARCHIVESSPACE_USER=#{node["archivesspace"]["user"]["name"]}/g' #{aspace_path}/archivesspace.sh"
end

execute "set-archivesspace-java_xmx" do
  command "sed -i '/ASPACE_JAVA_XMX=/c ASPACE_JAVA_XMX=\"-Xmx#{node['archivesspace']['java_xmx']}m\"' #{aspace_path}/archivesspace.sh"
end

remote_file "#{aspace_path}/lib/mysql-connector-java-#{node['archivesspace']['mysql_lib']}.jar" do
  source "#{node['archivesspace']['mysql_url']}/#{node['archivesspace']['mysql_lib']}/mysql-connector-java-#{node['archivesspace']['mysql_lib']}.jar" 
  mode "0644"
  action :create_if_missing
end

execute "reset-archivesspace-permissions" do
  command "chown -R #{node['archivesspace']['user']['name']}: #{node['archivesspace']['user']['home']}"
end

# download a plugin if specified
if node['archivesspace']['plugin_url'] and node['archivesspace']['plugin_name']
  git "#{aspace_path}/plugins/#{node['archivesspace']['plugin_name']}" do
    repository node['archivesspace']['plugin_url']
    user       node["archivesspace"]["user"]["name"]
    group      node["archivesspace"]["user"]["group"]
  end
end

unless node['archivesspace']['db']['embedded']
  db_host = node['archivesspace']['db']['host']
  db_port = node['archivesspace']['db']['port']
  db_name = node['archivesspace']['db']['name']
  db_user = node['archivesspace']['db']['user']
  db_pass = node['archivesspace']['db']['password']
  db      = "jdbc:mysql://#{db_host}:#{db_port}/#{db_name}?user=#{db_user}&password=#{db_pass}&useUnicode=true&characterEncoding=UTF-8"
end

# apply archivesspace configuration
template "#{aspace_path}/config/config.rb" do
  source "config.rb.erb"
  owner  node["archivesspace"]["user"]["name"]
  group  node["archivesspace"]["user"]["group"]
  mode   "0644"
  variables(
    :data => node['archivesspace']['user']['data'],
    :indexing_frequency => node['archivesspace']['indexing_frequency'],
    :backend_url => node['archivesspace']['backend_url'],
    :frontend_url => node['archivesspace']['frontend_url'],
    :solr_url => node['archivesspace']['solr_url'],
    :public_url => node['archivesspace']['public_url'],
    :db_url => db,
    :plugin => node['archivesspace']['plugin_name'],
    :user_registration => node['archivesspace']['user_registration'],
    :help_enabled => node['archivesspace']['help_enabled']
  )
end

# seed the database if mysql
unless node['archivesspace']['db']['embedded']
  bash "archivesspace-seed-database" do
    user node["archivesspace"]["user"]["name"]
    cwd  "#{aspace_path}/scripts"
    code "./setup-database.sh"
  end
end

link "/etc/init.d/archivesspace" do
  to "#{aspace_path}/archivesspace.sh"
end

execute "add-archivesspace-init" do
  command "update-rc.d archivesspace defaults"
end

bash "archivesspace-start" do
  user "root"
  cwd  "#{aspace_path}"
  code "./archivesspace.sh start"
end
