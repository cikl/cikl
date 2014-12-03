require 'cikl/base_model'
require 'equalizer'

module Cikl
  module Observable

    class DnsAnswer < Cikl::BaseModel
      attribute :resolver, String
      attribute :name, String
      attribute :rr_class, String
      attribute :rr_type, String
      attribute :section, String
      attribute :ipv4, String
      attribute :ipv6, String
      attribute :fqdn, String

      include Equalizer.new(*attribute_set.map(&:name))
    end

  end
end
