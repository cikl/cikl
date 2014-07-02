[![Build Status](https://travis-ci.org/cikl/cikl.svg)](https://travis-ci.org/cikl/cikl)

# Cikl
Cikl is a cyber threat intelligence management system. It is a fork of the [Collective Intelligence Framework (CIF)](https://code.google.com/p/collective-intelligence-framework/), which aims for the same goal. The primary goals of this (currently experimental) fork is to improve speed, scalability, functionality, and ease of installation. 

The codebase will be evolved over time from Perl to Ruby (likely with an emphasis on JRuby). In the meantime, the project will likely consist of some hybrid of the two languages until we stabilize features. 

## Documentation
Currently? We haven't got much in the way of documentation. Please accept my appologies.

## Development Environment

### Prerequisites 
We use Vagrant, VirtualBox, and Puppet to manage our development environment. 
Vagrant takes care of initializing the virtual machine, and hands things off
to Puppet to handle the provisioning and setup. 

- Hardware
- Software Requirements
  - [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.3
    - Tested with VirtualBox 4.3.10 on OS X 10.9.2
  - [Vagrant](http://www.vagrantup.com/downloads.html) >= 1.5
    - Tested with Vagrant 1.5.3 on OS X 10.9.2. 
    - I strongly recommend downloading and install the latest version of Vagrant. 
    - If your OS distribution provides Vagrant as a package, it will very likely be very out of date and not work. 

### Starting the development environment

- Clone and start up the Vagrant VM:
```
git clone https://github.com/cikl/cikl.git
cd cikl
```
- Bring up the virtual machine:
```
vagrant up
```
- That's it! You should now be able to access the environment.

### Accessing the development environment

- [API Documentation](http://localhost:8080/api/doc/)
- [Elasticsearch Head](http://localhost:9292/_plugin/head/)
- For shell access, type ```vagrant ssh```, and you'll be dropped into the 
  virtual machine as the 'vagrant' user. You'll notice that the base of the
  git repository has been mounted at '/vagrant'. You should have full sudo 
  privileges.

### Shutting down the development environment
With Vagrant, it's easy to forget that you've got a virtual machine running in 
the background. If you're done for the day, you can shut the VM down using:
```vagrant halt```

### Updating 
This is an actively developed project, so you'll want to keep things up to
date. 

```
# Stop your virtual machine:
vagrant halt
# OPTIONAL: Destroy the existing vagrant virtual machine. We only do this
# when material changes have been made to Vagrantfile or the puppet/ directory.
vagrant destroy
# Switch to your master branch
git checkout master
# Pull any updatream changes into your master branch
git pull origin master
# Recreate the vagrant virtual machine.
vagrant up
```

### Importing data via cikl_smrt

Now that you've got everything up and running, maybe you want to process a 
feed or two? 

At the moment, importing data involves running cikl_smrt against one of the 
feeds located in the 'feeds' directory. 

For example: 
```
vagrant ssh -c "cikl_smrt -C /etc/cikl.conf -r /vagrant/feeds/etc/00_alexa_whitelist.cfg -f top1000 -v5 -d"
```

### Clearing out existing data after an upgrade
```
vagrant ssh -c "/vagrant/util/drop_data.sh"
```

### Importing and exporting data via util/data_loader.sh

This tool exists for development purposes, only, and is not to be seen as a
means for actually backing up data within Cikl. 

#### Dumping the contents of Cikl into an archive:
```
vagrant ssh -c "/vagrant/util/data_loader.sh dump /vagrant/my_dump.tgz"
```


#### Restoring Cikl from a dump
NOTE: This will wipe out any data that is contained within Cikl!!! 
```
vagrant ssh -c "/vagrant/util/data_loader.sh restore /vagrant/my_dump.tgz"
```

### FAQ:

#### Why do I get prompted to select a network interface when I run 'vagrant up'? Why do you require bridged network access?
Normally, virtual machine traffic would be handled by the VirtualBox NAT 
process. However, I've found in testing that the Cikl's high-speed DNS resolver
quickly overwhelms VirtualBox's NAT socket tracking. In order to get around 
this hurdle, we've enabled bridged network access on the development VM. As a result,
you will be prompted to select a network adapter with which to bridge. If you 
see this message, select your primary network adapter.

If you want to disable this behavior, add ```bridge_networking: true``` to your
vagrantconfig_local.yaml, and run ```vagrant reload```


## Roadmap
You can find our roadmap [here](https://github.com/cikl/cikl/wiki/Roadmap).


## Contributing and Issue Tracking

Before you file a bug or submit a pull request, please review our 
[contribution guidelines](https://github.com/cikl/cikl/wiki/Contributing).

All issues are managed within the primary repository: [cikl/cikl/issues](https://github.com/cikl/cikl/issues). Pull requests should be sent to their respective reposirotires, referencing some issue within the main project repository.

We use Huboard for managing our issues (to the extent that it can). [Our HuBoard!](https://huboard.com/cikl/cikl#/).

## Repositories

Cikl consists of many different sub-projects. The main ones are:

### p5-Cikl
[cikl/p5-Cikl](https://github.com/cikl/p5-Cikl) - the current core of Cikl. This began as a fork of https://github.com/collectiveintel/cif-v1 and has evolved quite a bit over time. The code is available on CPAN as Cikl. 


## License

Copyright (c) 2014 Michael Ryan. See the LICENSE file for license rights and limitations (LGPLv3).
