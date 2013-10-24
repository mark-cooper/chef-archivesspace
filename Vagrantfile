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
      "recipe[chef-archivesspace]",
    ]
  end
end
