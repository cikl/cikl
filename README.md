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

- Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Install [Vagrant](http://www.vagrantup.com/downloads.html)

### Starting the development environment

- Clone and start up the Vagrant VM:
```
git clone https://github.com/cikl/cikl.git
cd cikl
git submodule update --init
```
- Bring up the virtual machine:
```
vagrant up
```
- That's it! You should now be able to access the environment.

### Accessing the development environment

- [Cikl Kibana dashboard](http://localhost:8080/)
- [Elasticsearch Head](http://localhost:8080/es/_plugin/head/)
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

- 
```
# Stop your virtual machine:
vagrant halt
# OPTIONAL: Destroy the existing vagrant virtual machine. We only do this
# when material changes have been made to Vagrantfile or the puppet/ directory.
vagrant destroy
# Switch to your master branch
git checkout master
# Sync remote references from the main repository:
git fetch origin
# Pull any updatream changes into your master branch
git pull origin master
# Very important, update any submodules:
git submodule update --init
# Recreate the vagrant virtual machine.
vagrant up
```

## Roadmap
You can find our roadmap [here](https://github.com/cikl/cikl/wiki/Roadmap).

## Issues and Pull Requests

All issues are managed within the primary repository: [cikl/cikl/issues](https://github.com/cikl/cikl/issues). Pull requests should be sent to their respective reposirotires, referencing some issue within the main project repository.

## Repositories

Cikl consists of many different sub-projects. The main ones are:

### p5-Cikl
[cikl/p5-Cikl](https://github.com/cikl/p5-Cikl) - the current core of Cikl. This began as a fork of https://github.com/collectiveintel/cif-v1 and has evolved quite a bit over time. The code is available on CPAN as Cikl. 

