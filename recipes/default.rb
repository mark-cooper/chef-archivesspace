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

if !node['archivesspace']['db']['embedded'] and node['archivesspace']['db']['host'] == "localhost"
  include_recipe "cron"
  include_recipe "mysql::server"
end

archivesspace_dir = "#{node['archivesspace']['user']['home']}/archivesspace"
db                = nil # will pickup value if mysql enabled

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
  command "sed -i 's/ARCHIVESSPACE_USER=/ARCHIVESSPACE_USER=#{node["archivesspace"]["user"]["name"]}/g' #{archivesspace_dir}/archivesspace.sh"
end

execute "set-archivesspace-java_xmx" do
  command "sed -i '/ASPACE_JAVA_XMX=/c ASPACE_JAVA_XMX=\"-Xmx#{node['archivesspace']['java_xmx']}m\"' #{archivesspace_dir}/archivesspace.sh"
end

remote_file "#{archivesspace_dir}/lib/mysql-connector-java-#{node['archivesspace']['mysql_lib']}.jar" do
  source "#{node['archivesspace']['mysql_url']}/#{node['archivesspace']['mysql_lib']}/mysql-connector-java-#{node['archivesspace']['mysql_lib']}.jar" 
  mode "0644"
  action :create_if_missing
end

execute "reset-archivesspace-permissions" do
  command "chown -R #{node['archivesspace']['user']['name']}: #{node['archivesspace']['user']['home']}"
end

# download a plugin if specified
if node['archivesspace']['plugin_url'] and node['archivesspace']['plugin_name']
  git "#{archivesspace_dir}/plugins/#{node['archivesspace']['plugin_name']}" do
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
  backups = node['archivesspace']['user']['backups']

  if db_host == "localhost"
    mysql_database db_name do
      connection(
        :host     => db_host,
        :username => 'root',
        :password => node['mysql']['server_root_password'],
        :encoding => 'utf8'
      )
      action :create
    end

    mysql_database_user db_user do
      connection    ( {:host => db_host, :username => 'root', :password => node['mysql']['server_root_password']} )
      password      db_pass
      database_name db_name
      privileges    [ :all ]
      action        :grant
    end

    cron_d 'archivesspace-backup' do
      minute  30
      hour    0
      command "#{archivesspace_dir}/scripts/backup.sh --mysqldump --output #{backups}/#{node['hostname']}_#{db_name}_`date +%F`.zip"
      user    node["archivesspace"]["user"]["name"]
    end    
  end
end

# apply archivesspace configuration
template "#{archivesspace_dir}/config/config.rb" do
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
    cwd  "#{archivesspace_dir}/scripts"
    code "./setup-database.sh"
  end
end

link "/etc/init.d/archivesspace" do
  to "#{archivesspace_dir}/archivesspace.sh"
end

execute "add-archivesspace-init" do
  command "update-rc.d archivesspace defaults"
end

bash "archivesspace-start" do
  user "root"
  cwd  "#{archivesspace_dir}"
  code "./archivesspace.sh start"
end

###### THE END