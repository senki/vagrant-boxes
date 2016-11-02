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
    precise.vm.provision "shell", path: "src/precise.sh", args: ["prod"]
    precise.vm.provision "reload"
    cache_dir = local_cache(precise.vm.box)
    precise.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    precise.vm.provider "virtualbox" do |v|
      v.name = precise.vm.hostname
      # serial port
      v.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end
  end

  config.vm.define "trusty" do |trusty|
    trusty.ssh.insert_key = false
    trusty.vm.box = "ubuntu/trusty64"
    trusty.vm.hostname = "senki-trusty.local"
    trusty.vm.provision "shell", path: "src/trusty.sh", args: ["prod"]
    trusty.vm.provision "reload"
    cache_dir = local_cache(trusty.vm.box)
    trusty.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    trusty.vm.provider "virtualbox" do |v|
      v.name = trusty.vm.hostname
      # serial port
      v.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
      v.memory = 1024
    end
  end

  config.vm.define "xenial" do |xenial|
    xenial.ssh.insert_key = false
    xenial.vm.box = "ubuntu/xenial64"
    xenial.vm.hostname = "senki-xenial.local"
    xenial.vm.provision "shell", path: "src/xenial.sh", args: ["prod"]
    xenial.vm.provision "reload"
    cache_dir = local_cache(xenial.vm.box)
    xenial.vm.synced_folder ".", "/vagrant/"
    xenial.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    xenial.vm.provider "virtualbox" do |v|
      v.name = xenial.vm.hostname
      # serial port
      v.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
      v.memory = 2048
    end
  end

  # test

  config.vm.define "precise_test" do |precise_test|
    precise_test.vm.box = "ubuntu/precise64"
    precise_test.vm.hostname = "senki-precise-test.local"
    precise_test.vm.network "private_network", ip:"192.168.33.14"
    precise_test.vm.provision "shell", path: "src/precise.sh", args: ["test"]
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
      # serial port
      v.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end
  end

  config.vm.define "trusty_test" do |trusty_test|
    trusty_test.vm.box = "ubuntu/trusty64"
    trusty_test.vm.hostname = "senki-trusty-test.local"
    trusty_test.vm.network "private_network", ip:"192.168.33.15"
    trusty_test.vm.provision "shell", path: "src/trusty.sh", args: ["test"]
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
      # serial port
      v.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
      v.memory = 1024
    end
  end

  config.vm.define "xenial_test" do |xenial_test|
    xenial_test.vm.box = "ubuntu/xenial64"
    xenial_test.vm.hostname = "senki-xenial-test.local"
    xenial_test.vm.network "private_network", ip:"192.168.33.16"
    xenial_test.vm.provision "shell", path: "src/xenial.sh", args: ["test"]
    xenial_test.vm.provision "reload"
    cache_dir = local_cache(xenial_test.vm.box)
    xenial_test.vm.synced_folder cache_dir, "/var/cache/apt/archives/"
    xenial_test.vm.synced_folder "vagrant/test", "/var/www/html",
        id: "www-data",
        owner: "www-data",
        group: "www-data",
        mount_options: ["dmode=775,fmode=664"]
    xenial_test.vm.provider "virtualbox" do |v|
      v.name = xenial_test.vm.hostname
      # serial port
      v.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
      v.memory = 2048
    end
  end

end
