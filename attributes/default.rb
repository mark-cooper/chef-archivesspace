
# General ArchivesSpace settings
default['archivesspace']['version']           = "1.0.0"
default['archivesspace']['url']               = "https://github.com/archivesspace/archivesspace/releases/download"
default['archivesspace']['mysql_url']         = "http://repo1.maven.org/maven2/mysql/mysql-connector-java"
default['archivesspace']['mysql_lib']         = "5.1.24"
default['archivesspace']['plugin_url']        = nil
default['archivesspace']['plugin_name']       = nil
default['archivesspace']['java_xmx']          = "1024"

# ArchivesSpace user settings
default['archivesspace']['user']['name']      = "archivesspace"
default['archivesspace']['user']['group']     = default['archivesspace']['user']['name']
default['archivesspace']['user']['home']      = "/home/#{default['archivesspace']['user']['name']}"
default['archivesspace']['user']['data']      = "/home/#{default['archivesspace']['user']['name']}/data"
default['archivesspace']['user']['backups']   = "/home/#{default['archivesspace']['user']['name']}/backups"

# Database settings -- apply only if embedded is false
default['archivesspace']['db']['embedded']    = true
default['archivesspace']['db']['host']        = "localhost"
default['archivesspace']['db']['port']        = "3306"
default['archivesspace']['db']['name']        = default['archivesspace']['user']['name']
default['archivesspace']['db']['user']        = default['archivesspace']['user']['name']
default['archivesspace']['db']['password']    = default['archivesspace']['user']['name']

# ArchivesSpace settings
default['archivesspace']['directory']         = "#{default['archivesspace']['user']['home']}/archivesspace"
default['archivesspace']['indexing_frequency']= 30
default['archivesspace']['backend_url']       = "8089"
default['archivesspace']['frontend_url']      = "8080"
default['archivesspace']['solr_url']          = "8090"
default['archivesspace']['public_url']        = "8081"
default['archivesspace']['user_registration'] = false
default['archivesspace']['help_enabled']      = false

# Proxy settings -- apply only if proxy use is true
default['archivesspace']['proxy']['frontend_server_names'] = "staff.archive.org"
default['archivesspace']['proxy']['public_server_names']   = "archive.org www.archive.org"
default['archivesspace']['proxy']['ssl_server_name']       = "www.archive.org"
default['archivesspace']['proxy']['enable_cache']          = false
default['archivesspace']['proxy']['cache_path']            = "/tmp/nginx/cache"
default['archivesspace']['proxy']['cache_name']            = "CACHE"
default['archivesspace']['proxy']['cache_size']            = "1g"
default['archivesspace']['proxy']['cache_valid']           = "1m"
