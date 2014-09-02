require 'virtus'
require 'cikl/observable/dns_answer'
require 'cikl/observable/ipv4'
require 'cikl/observable/fqdn'

module Cikl
  class Observables 
    include Virtus.model

    attribute :ipv4, Array[Cikl::Observable::Ipv4]
    attribute :fqdn, Array[Cikl::Observable::Fqdn]
    attribute :dns_answer, Array[Cikl::Observable::DnsAnswer]

    class << self
      alias_method :from_hash, :new
    end
  end
end

