require 'grape'
require 'grape-entity'
module Cikl
  module API
    module Entities
      module Observable
        class DnsAnswer < Grape::Entity
          expose :resolver
          expose :name
          expose :rr_class
          expose :rr_type
          expose :section
          expose :ipv4, unless: lambda { |e,o| e.ipv4.nil? }
          expose :ipv6, unless: lambda { |e,o| e.ipv6.nil? }
          expose :fqdn, unless: lambda { |e,o| e.fqdn.nil? }
        end
      end
    end
  end
end
