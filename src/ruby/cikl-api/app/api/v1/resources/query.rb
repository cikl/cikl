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

          desc 'Query events', {
            entity: Cikl::API::Entities::Response
          }

          params do
            requires :none, using: Cikl::API::Entities::QueryParams.documentation
          end

          post :query do
            run_standard_query(params)
          end
        end
      end

    end
  end
end
