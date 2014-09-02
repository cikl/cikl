require 'virtus'

module Cikl
  module Observable

    class DnsAnswer
      include Virtus.model

      attribute :resolver, String
      attribute :name, String
      attribute :rr_class, String
      attribute :rr_type, String
      attribute :section, String
      attribute :ipv4, String
      attribute :ipv6, String
      attribute :fqdn, String

      class << self
        alias_method :from_hash, :new
      end
    end

  end
end
