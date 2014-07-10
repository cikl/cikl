require 'grape'
require 'grape-entity'
require 'api/entities/query_params'
require 'api/entities/event'
require 'api/entities/timing'
require 'api/entities/facets'

module Cikl
  module API
    module Entities
      class Response < Grape::Entity
        expose :count, 
          documentation: { 
            type: 'integer', 
            desc: 'The number of events returned in this set' 
        } do |e,o| 
          e.events.count
        end

        expose :total_events, 
          documentation: { 
            type: 'integer', 
            desc: 'The total number of events that match the query'
          }

        expose :query,
           using: Cikl::API::Entities::QueryParams,
           documentation:
           {
             desc: 'The query parameters used to return this set of events'
           }

        expose :events, 
          using: Cikl::API::Entities::Event, 
          documentation: { 
            desc: 'The set of events matching the query' 
          }

        expose :timing,
          using: Cikl::API::Entities::Timing,
          if: { timing: 1 },
          documentation:
          {
            desc: 'Timing data for the query and rendering of results'
          }

        expose :facets,
          using: Cikl::API::Entities::Facets,
          documentation: 
          {
            desc: 'Faceting information'
          }

      end
    end
  end
end

