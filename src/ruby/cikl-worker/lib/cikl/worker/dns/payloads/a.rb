require 'cikl/worker/dns/payloads/base'

module Cikl
  module Worker
    module DNS
      module Payloads
        class A < Base
          attr_reader :ipv4
          def initialize(name, ttl, ipv4)
            super(name, ttl, :IN, :A)
            @ipv4 = ipv4
          end

          def ==(other)
            super(other) &&
              @ipv4 == other.ipv4
          end

          # @return [Hash] a hash version of the payload.
          def dns_answer
            super().merge({
              :ipv4 => @ipv4.to_s
            })
          end

          def self.from_rr(name, ttl, rr)
            new(name, ttl, rr.address)
          end
        end
      end
    end
  end
end

