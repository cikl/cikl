require 'cikl/worker/dns/payloads/base'

module Cikl
  module Worker
    module DNS
      module Payloads
        class AAAA < Base
          attr_reader :ipv6
          def initialize(name, ttl, ipv6)
            super(name, ttl, :IN, :AAAA)
            @ipv6 = ipv6 
          end

          def ==(other)
            super(other) &&
              @ipv6 == other.ipv6
          end

          # @return [Hash] a hash version of the payload.
          def dns_answer
            super().merge({
              :ipv6 => @ipv6.to_s.downcase
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


