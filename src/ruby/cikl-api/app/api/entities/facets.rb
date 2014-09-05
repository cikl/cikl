require 'grape'
require 'grape-entity'

module Cikl
  module API
    module Entities
      class Facets < Grape::Entity
        format_with(:iso_timestamp) { |dt| dt.iso8601 if dt.respond_to?(:iso8601) }

        with_options(format_with: :iso_timestamp) do
          expose :min_detect_time
          expose :max_detect_time
          expose :min_import_time
          expose :max_import_time
        end

        expose :sources
        expose :feed_providers
        expose :feed_names
      end
    end
  end
end


