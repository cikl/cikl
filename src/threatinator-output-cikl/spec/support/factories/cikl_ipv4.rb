require 'cikl/observable/ipv4'

FactoryGirl.define do
  factory :cikl_ipv4, class: Cikl::Observable::Ipv4 do
    ipv4 { '1.2.3.4' } 
  end
end


