# Puppet module: perl

This is a Puppet module to manage perl and perl modules on CPAN.

Based on Example42 layouts by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-perl

Module development sponsored by [JobRapido](http://www.jobrapido.com)

Released under the terms of Apache 2 License.

This module requires the presence of Example42 Puppi module in your modulepath.

## USAGE - Modules installation

* Install a module via CPAN Minus

        perl::module { 'Path::Class': }

* Install a module via CPAN command

        perl::cpan::module { 'Path::Class': }

* Remove a module previously installed via CPAN Minus

        perl::module { 'Path::Class':
          ensure => absent,
        }

* Install a module using the OS packages

        perl::module { 'YAML::Perl':
          use_package => true,
        }

Note that the prefix name of the package (perl-) is automatically added and the :: are converted to -.
The actual package installed in this case is therefore: perl-YAML-Perl 

* Install a module from the given url

        perl::module { 'My::Module':
          url => 'http://repo.example42.com/perl/my-module.tgz',
        }

* Install a module (via cpan) setting environment variables

        perl::module { 'Path::Class':
          exec_environment => [ "http_proxy=http://proxy.example42.com:8080" , "https_proxy=https://proxy.example42.com:8080" ],
        }


## USAGE - Basic management

* Install perl with default settings

        class { 'perl': }

* Install a specific version of perl package

        class { 'perl':
          version => '1.0.1',
        }

* Remove perl resources

        class { 'perl':
          absent => true
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'perl':
          noops => true
        }

* Automatically include a custom subclass

        class { 'perl':
          my_class => 'example42::my_perl',
        }

