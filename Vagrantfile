# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "archivesspace"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 2048]
  end 

  config.vm.network "private_network", ip: "10.11.12.14"
  config.vm.network :forwarded_port, guest: 80,   host: 3001
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 8081, host: 8081

  config.berkshelf.enabled = true
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :archivesspace => {
        :help_enabled => true,
        :db => {
          :embedded => false,
        },
        :proxy => {
          :enable_cache => true,
        },
      },
      :mysql => {
        :allow_remote_root => false,
        :bind_address => 'localhost',
        :remove_anonymous_users => true,
        :remove_test_database => true,
        :server_root_password => 'root',
        :server_debian_password => 'root',
        :server_repl_password => 'root',
      },
      :nginx => {
        :enable_rate_limiting => true,
        :rate_limiting_zone_name => 'blitz',
	:rate_limit => '8r/s',
      }
    }

    chef.run_list = [
      "recipe[apt]",
      "recipe[chef-archivesspace::mysql]",
      "recipe[chef-archivesspace::default]",
      "recipe[chef-archivesspace::proxy]",
      "recipe[chef-archivesspace::monit]",
    ]
  end
end
