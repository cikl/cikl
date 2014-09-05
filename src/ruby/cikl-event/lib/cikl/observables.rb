require 'cikl/base_model'
require 'cikl/observable/dns_answer'
require 'cikl/observable/ipv4'
require 'cikl/observable/fqdn'
require 'equalizer'

module Cikl
  class Observables < Cikl::BaseModel
    attribute :ipv4, Array[Cikl::Observable::Ipv4]
    attribute :fqdn, Array[Cikl::Observable::Fqdn]
    attribute :dns_answer, Array[Cikl::Observable::DnsAnswer]

    include Equalizer.new(*attribute_set.map(&:name))

    def to_serializable_hash
      ret = {}
      attributes.each_pair do |k,v|
        next if v.nil?
        next if v.empty?
        v = v.map {|x| x.to_serializable_hash }
        ret[k] = v
      end
      ret
    end

  end
end

