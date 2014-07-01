require 'grape'
require 'grape-entity'
require 'api/entities/observable/dns_answer'
require 'api/entities/observable/ipv4'
require 'api/entities/observable/fqdn'

module Cikl
  module API
    module Entities
      class Observables < Grape::Entity
        expose :dns_answer, 
          using: Cikl::API::Entities::Observable::DnsAnswer,
          unless: lambda { |e,o| e.dns_answer.empty? }
        expose :ipv4, 
          using: Cikl::API::Entities::Observable::Ipv4,
          unless: lambda { |e,o| e.ipv4.empty? }
        expose :fqdn, 
          using: Cikl::API::Entities::Observable::Fqdn,
          unless: lambda { |e,o| e.fqdn.empty? }
      end
    end
  end
end

