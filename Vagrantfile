# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
 
# Load up our vagrant config files -- vagrantconfig.yaml first
_config = YAML.load(File.open(File.join(File.dirname(__FILE__),
                    "vagrantconfig.yaml"), File::RDONLY).read)

# Local-specific/not-git-managed config -- vagrantconfig_local.yaml
begin
  _local_config = YAML.load(File.open(File.join(File.dirname(__FILE__),
                 "vagrantconfig_local.yaml"), File::RDONLY).read)
  if _local_config
    _config.merge!(_local_config)
  end

rescue Errno::ENOENT # No vagrantconfig_local.yaml found -- that's OK; just
                     # use the defaults.
end

CONF = _config

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require_relative 'vagrant/ubuntu_trusty'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  use_nfs = (CONF['nfs'] == true) && !  Vagrant::Util::Platform.windows?

  config.vm.synced_folder ".", '/vagrant', :nfs => use_nfs

  config.vm.define "cikl" do |cikl|
    # Every Vagrant virtual environment requires a box to build off of.
    cikl.vm.box = CONF['virtual_box_name']
    cikl.vm.hostname = "cikl"

    cikl.vm.network :private_network, 
      :ip      => CONF['eth1_ip_address'], 
      :netmask => CONF['eth1_netmask'],
      :adapter => 2, 
      :auto_config => true


    # Route using the bridged network so that our DNS resolver doesn't nuke 
    # the NAT tables. 
    if CONF['bridge_networking'] == true
      cikl.vm.network :public_network, :adapter => 3, :auto_config => true,
        :use_dhcp_assigned_default_route => true
    end

    cikl.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--cpus", CONF['number_cpus']]
      v.customize ["modifyvm", :id, "--memory", CONF['memory_size']]
    end

    cikl.vm.network :forwarded_port, guest: 80, host: 8080 
    #cikl.vm.network :forwarded_port, guest: 9200, host: 9200
    
    cikl.vm.provision :puppet do |puppet|
      puppet.manifests_path     = "puppet/manifests"
      puppet.manifest_file      = "default.pp"
      puppet.module_path        = ['puppet/private_modules', 'puppet/modules']
      puppet.hiera_config_path  = "puppet/hiera.yaml"
      puppet.working_directory  = "/vagrant/puppet"
      puppet.facter = {
        'env'                  => 'dev',
      }
      if (use_nfs == true) 
        puppet.synced_folder_type = 'nfs'
      end
    end
  end
end
