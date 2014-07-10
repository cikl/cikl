require 'virtus'

module Cikl
  module Models
    class Facets
      include Virtus.model
      attribute :min_detect_time, DateTime
      attribute :max_detect_time, DateTime
      attribute :min_import_time, DateTime
      attribute :max_import_time, DateTime
      attribute :sources, Array
      attribute :feed_providers, Array
      attribute :feed_names, Array
    end
  end
end


