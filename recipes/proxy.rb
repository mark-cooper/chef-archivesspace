#
# Cookbook Name:: chef-archivesspace
# Recipe:: proxy
#
# GPL v3 2013 Mark Cooper
# 

include_recipe "nginx"

directory node['archivesspace']['proxy']['cache_path'] do
  owner node['nginx']['user']
  group node['nginx']['user']
  mode "0755"
  recursive true
  action :create
end  

template "#{node['nginx']['dir']}/conf.d/cache.conf" do
  source "nginx.server.cache.erb"
  mode "0644"
  variables(
    :cache_path => node['archivesspace']['proxy']['cache_path'],
    :cache_name => node['archivesspace']['proxy']['cache_name'],
    :cache_size => node['archivesspace']['proxy']['cache_size']
  )
end

template "#{node['nginx']['dir']}/sites-available/#{node["archivesspace"]["user"]["name"]}" do
  source "nginx.server.conf.erb"
  mode "0644"
  variables(
    :enable_rate_limiting => node['nginx']['enable_rate_limiting'],
    :zone => node['nginx']['rate_limiting_zone_name'],
    :frontend_server_names => node['archivesspace']['proxy']['frontend_server_names'],
    :frontend_port => node['archivesspace']['frontend_url'],
    :public_server_names => node['archivesspace']['proxy']['public_server_names'],
    :public_port => node['archivesspace']['public_url'],
    :ssl_server_name => node['archivesspace']['proxy']['ssl_server_name'],
    :ssl_port => node['archivesspace']['frontend_url'],
    :enable_cache => node['archivesspace']['proxy']['enable_cache'],
    :cache_name => node['archivesspace']['proxy']['cache_name'],
    :cache_valid => node['archivesspace']['proxy']['cache_valid']
  )
end

nginx_site 'default' do
  enable false
end

nginx_site node["archivesspace"]["user"]["name"] do
  enable true
end 
