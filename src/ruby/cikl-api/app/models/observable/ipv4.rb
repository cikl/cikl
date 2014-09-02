require 'virtus'

module Cikl
  module Models
    module Observable

      class Ipv4
        include Virtus.model
        attribute :ipv4

        class << self
          alias_method :from_hash, :new
        end
      end

    end
  end
end

