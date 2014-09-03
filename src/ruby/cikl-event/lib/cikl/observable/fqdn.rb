require 'virtus'

module Cikl
  module Observable

    class Fqdn 
      include Virtus.model
      attribute :fqdn, String

      class << self
        alias_method :from_hash, :new
      end
    end

  end
end