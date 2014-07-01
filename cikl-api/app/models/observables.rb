require 'virtus'
require 'models/observable/dns_answer'
require 'models/observable/ipv4'
require 'models/observable/fqdn'

module Cikl
  module Models
    class Observables 
      include Virtus.model

      attribute :ipv4, Array[Cikl::Models::Observable::Ipv4]
      attribute :fqdn, Array[Cikl::Models::Observable::Fqdn]
      attribute :dns_answer, Array[Cikl::Models::Observable::DnsAnswer]
      
      class << self
        alias_method :from_hash, :new
      end
    end
  end
end

