require 'grape'
require 'api/entities/query_params'
require 'api/helpers/query'
require 'date'

module Cikl
  module API
    module V1
      module Resources
        class Query < Grape::API
          helpers Cikl::API::Helpers::Query

          params do
            requires :none, using: Cikl::API::Entities::QueryParams.documentation
          end

          namespace :query do
            # ipv4 handling
            params do
              requires :ipv4, type: String, regexp: /^(\d{1,3}\.){3}(\d{1,3})$/
            end
            resource :ipv4 do
              IPV4_QUERY = [
                ["observables.ipv4", ["observables.ipv4.ipv4"]],
                ["observables.dns_answer", ["observables.dns_answer.ipv4"]],
              ]
              desc 'Query events by IPv4', {
                entity: Cikl::API::Entities::Response
              }
              post do
                value = params[:ipv4]
                run_standard_query do |z|
                  z.should(IPV4_QUERY)  do |path, fields|
                    es_nested_any(z, path, value, fields)
                  end
                end
              end # post
            end # ipv4

            # fqdn handling
            params do
              requires :fqdn, type: String
            end
            resource :fqdn do
              FQDN_QUERY = [
                ["observables.fqdn", ["observables.fqdn.fqdn"]],
                ["observables.dns_answer", ["observables.dns_answer.name", "observables.dns_answer.fqdn"]],
              ]

              desc 'Query events by fqdn', {
                entity: Cikl::API::Entities::Response
              }
              post do
                value = params[:fqdn]
                run_standard_query do |z|
                  z.should(FQDN_QUERY)  do |path, fields|
                    es_nested_any(z, path, value, fields)
                  end
                end
              end
            end

          end

          ###
        end
      end

    end
  end
end
