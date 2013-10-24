Chef ArchivesSpace cookbook
===========================
The Chef ArchivesSpace cookbook installs and configures ArchivesSpace according to the instructions at https://github.com/archivesspace/archivesspace/blob/master/README.md

By default it uses the embedded database which is suitable for testing and training. It can be configured to use MySQL, either on localhost (in which case the server is installed) or by pointing at an external server. In the latter case that server must be configured to allow communication from the ArchivesSpace server, with a database and user created that matches the attributes defined for this cookbook.

Post provisioning navigate to http://hostname:8080 (staff), http://hostname:8081 (public), or as appropriate if the port defaults have been changed. If using Vagrant with the included Vagrantfile that would be http://localhost:8080 and http://localhost:8081.

Installation
------------
Install the cookbook using knife:

    $ gem install knife-github-cookbooks
    $ knife cookbook github install mark-cooper/chef-archivesspace

Or, if you are using Berkshelf, add the cookbook to your Berksfile:

```ruby
cookbook 'archivesspace', git: 'https://github.com/mark-cooper/chef-archivesspace.git'
```

Usage
-----
Add the cookbook to your `run_list` in a node or role:

```json
{
  "run_list": [
    "recipe[archivesspace::default]"
  ]
}
```

Or include it in a recipe:

```ruby
# other_cookbook/metadata.rb
# ...
depends 'archivesspace'
```

```ruby
# other_cookbook/recipes/default.rb
# ...
include_recipe 'archivesspace::default'
```

Example embedded database Vagrant configuration:

    config.vm.provision :chef_solo do |chef|
      chef.run_list = [
        "recipe[apt]",
        "recipe[archivesspace::default]",
      ]
    end

Example local mysql database Vagrant configuration:

    config.vm.provision :chef_solo do |chef|
      chef.json = {
        :archivesspace => {
          :db => {
            :embedded => false,
          },
        },
        :mysql => {
          :bind_address => 'localhost',
          :server_root_password => 'root',
          :server_debian_password => 'root',
          :server_repl_password => 'root',
        }
      }

      chef.run_list = [
        "recipe[apt]",
        "recipe[archivesspace::default]",
      ]
    end

Attributes
----------
`node['archivesspace']` attributes:

<table>
    <thead>
        <tr>
            <th>Attribute</th>
            <th>Description</th>
            <th>Example</th>
            <th>Default</th>
        </tr>
    </thead>
  <tbody>
    <tr>
        <td>version</td>
        <td>version of archivesspace to install</td>
        <td><tt>1.0.0</tt></td>
        <td><tt>1.0.0</tt></td>
    </tr>
    <tr>
        <td>url</td>
        <td>directory url for download</td>
        <td><tt>...</tt></td>
        <td><tt>...</tt></td>
    </tr>
    <tr>
        <td>mysql_url</td>
        <td>directory url of the mysql connector</td>
        <td><tt>...</tt></td>
        <td><tt>...</td>
    </tr>
    <tr>
        <td>mysql_lib</td>
        <td>version of mysql connector to download</td>
        <td><tt>5.1.24</tt></td>
        <td><tt>5.1.24</tt></td>
    </tr>
    <tr>
        <td>plugin_url</td>
        <td>git url of a plugin repository</td>
        <td><tt>...</tt></td>
        <td><tt>nil</tt></td>
    </tr>
    <tr>
        <td>plugin_name</td>
        <td>name to give the plugin repository</td>
        <td><tt>awesome</tt></td>
        <td><tt>nil</tt></td>
    </tr>
    <tr>
        <td>java_xmx</td>
        <td>amount of ram to allocate to archivesspace</td>
        <td><tt>2048</tt></td>
        <td><tt>1024</tt></td>
    </tr>
    <tr>
        <td>indexing_frequency</td>
        <td>indexing frequency in seconds</td>
        <td><tt>60</tt></td>
        <td><tt>30</tt></td>
    </tr>    
    <tr>
        <td>backend_url</td>
        <td>backend port</td>
        <td><tt>9089</tt></td>
        <td><tt>8089</tt></td>
    </tr>    
    <tr>
        <td>backend_url</td>
        <td>backend port</td>
        <td><tt>9089</tt></td>
        <td><tt>8089</tt></td>
    </tr>
    <tr>
        <td>frontend_url</td>
        <td>frontend port</td>
        <td><tt>9080</tt></td>
        <td><tt>8080</tt></td>
    </tr>
    <tr>
        <td>solr_url</td>
        <td>solr port</td>
        <td><tt>9090</tt></td>
        <td><tt>8090</tt></td>
    </tr>
    <tr>
        <td>public_url</td>
        <td>public port</td>
        <td><tt>9081</tt></td>
        <td><tt>8081</tt></td>
    </tr>
    <tr>
        <td>user_registration</td>
        <td>allow arbitrary user registration</td>
        <td><tt>true</tt></td>
        <td><tt>false</tt></td>
    </tr>
    <tr>
        <td>help_enabled</td>
        <td>display links to help documentation</td>
        <td><tt>true</tt></td>
        <td><tt>false</tt></td>
    </tr>    
  </tbody>  
</table>

`node['archivesspace']['user']` attributes:

<table>
    <thead>
        <tr>
            <th>Attribute</th>
            <th>Description</th>
            <th>Example</th>
            <th>Default</th>
        </tr>
    </thead>
  <tbody>
    <tr>
        <td>name</td>
        <td>name of archivesspace application user</td>
        <td><tt>aspace</tt></td>
        <td><tt>archivesspace</tt></td>
    </tr>
    <tr>
        <td>group</td>
        <td>archivesspace group name</td>
        <td><tt>aspace</tt></td>
        <td><tt>archivesspace</tt></td>
    </tr>
    <tr>
        <td>home</td>
        <td>home directory of archivesspace user</td>
        <td><tt>/home/aspace</tt></td>
        <td><tt>/home/archivesspace</tt></td>
    </tr>
    <tr>
        <td>data</td>
        <td>data directory for archivesspace</td>
        <td><tt>/home/aspace/data</tt></td>
        <td><tt>/home/archivesspace/data</tt></td>
    </tr>
    <tr>
        <td>backups</td>
        <td>backup directory for archivesspace</td>
        <td><tt>/home/aspace/backups</tt></td>
        <td><tt>/home/archivesspace/backups</tt></td>
    </tr>
  </tbody>  
</table>

`node['archivesspace']['db']` attributes:

<table>
    <thead>
        <tr>
            <th>Attribute</th>
            <th>Description</th>
            <th>Example</th>
            <th>Default</th>
        </tr>
    </thead>
  <tbody>
    <tr>
        <td>embedded</td>
        <td>use the embedded database for archivesspace</td>
        <td><tt>false</tt></td>
        <td><tt>true</tt></td>
    </tr>
    <tr>
        <td>host</td>
        <td>mysql host</td>
        <td><tt>mysql.archive.org</tt></td>
        <td><tt>localhost</tt></td>
    </tr>
    <tr>
        <td>port</td>
        <td>mysql port</td>
        <td><tt>1234</tt></td>
        <td><tt>3306</tt></td>
    </tr>
    <tr>
        <td>name</td>
        <td>database name for archivesspace</td>
        <td><tt>aspace</tt></td>
        <td><tt>archivesspace user name</tt></td>
    </tr>
    <tr>
        <td>user</td>
        <td>name for archivesspace database user</td>
        <td><tt>aspace</tt></td>
        <td><tt>archivesspace user name</tt></td>
    </tr>
    <tr>
        <td>password</td>
        <td>password for archivesspace database user</td>
        <td><tt>123456</tt></td>
        <td><tt>archivesspace user name</tt></td>
    </tr>
  </tbody>  
</table>

Notes on the database attributes:

- If the embedded database is being used (embedded is true) then the mysql settings are ignored
- If mysql is being used (embedded is false):
    - mysql will run locally if host is "localhost"
        - database called "name" will be created
        - database user called "user" will be created with "password"
        - all privileges are granted on database "name" for "user"
    - otherwise will attempt to connect to an external database called "name" with "user" and "password"

License & Authors
-----------------
- Author:: Mark Cooper (<mark.cooper@lyrasis.org>)

GPL v3
