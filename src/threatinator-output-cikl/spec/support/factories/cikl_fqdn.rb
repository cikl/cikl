require 'cikl/observable/fqdn'

FactoryGirl.define do
  factory :cikl_fqdn, class: Cikl::Observable::Fqdn do
    fqdn { 'foobar.com' } 
  end
end



