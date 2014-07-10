require 'grape'
require 'grape-entity'
require 'api/entities/observables'
module Cikl
  module API
    module Entities
      class Event < Grape::Entity
        format_with(:iso_timestamp) { |dt| dt.iso8601 if dt.respond_to?(:iso8601) }

        with_options(format_with: :iso_timestamp) do
          expose :import_time
          expose :detect_time
        end
        expose :source
        expose :feed_name
        expose :feed_provider
        expose :observables, using: Cikl::API::Entities::Observables
      end
    end
  end
end
