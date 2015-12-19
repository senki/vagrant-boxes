# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

def local_cache(box_name)
  cache_dir = File.join(File.expand_path("~/.vagrant.d"),
                        'cache',
                        'apt',
                        box_name)
  partial_dir = File.join(cache_dir, 'partial')
  FileUtils.mkdir_p(partial_dir) unless File.exists? partial_dir
  cache_dir
end

Vagrant.configure(2) do |config|

  # build

  config.vm.define "precise" do |precise|
    precise.ssh.insert_key = false
    precise.vm.box = "ubuntu/precise64"
    precise.vm.hostname = "senki-precise.local"
    precise.vm.provision "shell", path: "src/precise.sh", args: ["prod", "5"]
    precise.vm.provision "reload"
    cache_dir = local_cache(precise.vm.box)
    precise.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    precise.vm.provider "virtualbox" do |v|
      v.name = precise.vm.hostname
    end
  end

  config.vm.define "trusty" do |trusty|
    trusty.ssh.insert_key = false
    trusty.vm.box = "ubuntu/trusty64"
    trusty.vm.hostname = "senki-trusty.local"
    trusty.vm.provision "shell", path: "src/trusty.sh", args: ["prod", "5"]
    trusty.vm.provision "reload"
    cache_dir = local_cache(trusty.vm.box)
    trusty.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    trusty.vm.provider "virtualbox" do |v|
      v.name = trusty.vm.hostname
      v.memory = 1024
    end

  end

  config.vm.define "trusty_php7" do |trusty_php7|
    trusty_php7.ssh.insert_key = false
    trusty_php7.vm.box = "ubuntu/trusty64"
    trusty_php7.vm.hostname = "senki-trusty-php7.local"
    trusty_php7.vm.provision "shell", path: "src/trusty.sh", args: ["prod", "7"]
    trusty_php7.vm.provision "reload"
    cache_dir = local_cache(trusty_php7.vm.box)
    trusty_php7.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    trusty_php7.vm.provider "virtualbox" do |v|
      v.name = trusty_php7.vm.hostname
      v.memory = 2048
      v.cpus = 2
    end

  end

  # test

  config.vm.define "precise_test" do |precise_test|
    precise_test.vm.box = "ubuntu/precise64"
    precise_test.vm.hostname = "senki-precise-test.local"
    precise_test.vm.network "private_network", ip:"192.168.33.14"
    precise_test.vm.provision "shell", path: "src/precise.sh", args: ["test", "5"]
    precise_test.vm.provision "reload"
    cache_dir = local_cache(precise_test.vm.box)
    precise_test.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    precise_test.vm.synced_folder "vagrant/test", "/var/www",
        id: "www-data",
        owner: "www-data",
        group: "www-data",
        mount_options: ["dmode=775,fmode=664"]
    precise_test.vm.provider "virtualbox" do |v|
      v.name = precise_test.vm.hostname
    end
  end

  config.vm.define "trusty_test" do |trusty_test|
    trusty_test.vm.box = "ubuntu/trusty64"
    trusty_test.vm.hostname = "senki-trusty-test.local"
    trusty_test.vm.network "private_network", ip:"192.168.33.15"
    trusty_test.vm.provision "shell", path: "src/trusty.sh", args: ["test", "5"]
    trusty_test.vm.provision "reload"
    cache_dir = local_cache(trusty_test.vm.box)
    trusty_test.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    trusty_test.vm.synced_folder "vagrant/test", "/var/www/html",
        id: "www-data",
        owner: "www-data",
        group: "www-data",
        mount_options: ["dmode=775,fmode=664"]
    trusty_test.vm.provider "virtualbox" do |v|
      v.name = trusty_test.vm.hostname
      v.memory = 1024
    end

  end

  config.vm.define "trusty_php7_test" do |trusty_php7_test|
    trusty_php7_test.vm.box = "ubuntu/trusty64"
    trusty_php7_test.vm.hostname = "senki-trusty-php7-test.local"
    trusty_php7_test.vm.network "private_network", ip:"192.168.33.16"
    trusty_php7_test.vm.provision "shell", path: "src/trusty.sh", args: ["test", "7"]
    trusty_php7_test.vm.provision "reload"
    cache_dir = local_cache(trusty_php7_test.vm.box)
    trusty_php7_test.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    trusty_php7_test.vm.synced_folder "vagrant/test", "/var/www/html",
        id: "www-data",
        owner: "www-data",
        group: "www-data",
        mount_options: ["dmode=775,fmode=664"]
    trusty_php7_test.vm.provider "virtualbox" do |v|
      v.name = trusty_php7_test.vm.hostname
      v.memory = 2048
      v.cpus = 2
    end

  end

end
