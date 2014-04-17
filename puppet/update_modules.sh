#!/bin/sh
apt-get install -y -qq git 
gem install --no-ri --no-rdoc librarian-puppet 

librarian-puppet install --verbose --clean
