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
            desc 'Query events', {
              entity: Cikl::API::Entities::Response
            }
            params do
              optional :ipv4, type: String, regexp: /^(\d{1,3}\.){3}(\d{1,3})$/
              optional :fqdn, type: String
            end
            post do
              run_standard_query(params)
            end

            # ipv4 handling
            params do
              requires :ipv4, type: String, regexp: /^(\d{1,3}\.){3}(\d{1,3})$/
            end
            resource :ipv4 do
              desc 'Query events by IPv4', {
                entity: Cikl::API::Entities::Response
              }
              post do
                run_standard_query(params)
              end # post
            end # ipv4

            # fqdn handling
            params do
              requires :fqdn, type: String
            end
            resource :fqdn do
              desc 'Query events by fqdn', {
                entity: Cikl::API::Entities::Response
              }
              post do
                run_standard_query(params)
              end
            end

          end

          ###
        end
      end

    end
  end
end
