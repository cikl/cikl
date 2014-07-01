require 'cikl/worker/dns/payloads/base'

module Cikl
  module Worker
    module DNS
      module Payloads
        class MX < Base
          attr_reader :fqdn
          def initialize(name, ttl, fqdn)
            super(name, ttl, :IN, :MX)
            @fqdn = fqdn
          end

          def ==(other)
            super(other) &&
              @fqdn == other.fqdn
          end

          # @return [Hash] a hash version of the payload.
          def dns_answer
            super().merge({
              :fqdn => @fqdn.to_s.downcase
            })
          end

          def self.from_rr(name, ttl, rr)
            new(name, ttl, rr.exchange)
          end
        end
      end
    end
  end
end




