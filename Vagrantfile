# -*- mode: ruby -*-
# vi: set ft=ruby :
 

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.synced_folder ".", "/vagrant", type: "rsync"


  config.vm.define "cikl" do |cikl|
    # Every Vagrant virtual environment requires a box to build off of.
    cikl.vm.box = "ubuntu/trusty64"

    cikl.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--memory", "2048"]
    end

    cikl.vm.network :forwarded_port, guest: 80, host: 8080 
    #cikl.vm.network :forwarded_port, guest: 9200, host: 9200
    
    cikl.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "default.pp"
      puppet.options        = '--modulepath /vagrant/puppet/private_modules:/vagrant/puppet/modules'
    end
  end

## This is just for testing to see if we can provision Centos6.5 ... Not done.
#  config.vm.define "centos6.5" do |cikl|
#    # Every Vagrant virtual environment requires a box to build off of.
#    cikl.vm.box = "centos6.5"
#    cikl.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130731.box"
#  end
end
