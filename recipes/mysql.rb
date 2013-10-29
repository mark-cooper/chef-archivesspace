#
# Cookbook Name:: chef-archivesspace
# Recipe:: mysql
#
# GPL v3 2013 Mark Cooper
# 

include_recipe "cron"
include_recipe "mysql::server"

aspace_path = node['archivesspace']['directory']
db_host     = node['archivesspace']['db']['host']
db_name     = node['archivesspace']['db']['name']
db_user     = node['archivesspace']['db']['user']
db_pass     = node['archivesspace']['db']['password']
backups     = node['archivesspace']['user']['backups']

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
  command "#{aspace_path}/scripts/backup.sh --mysqldump --output #{backups}/#{node['hostname']}_#{db_name}_`date +%F`.zip"
  user    node["archivesspace"]["user"]["name"]
end
