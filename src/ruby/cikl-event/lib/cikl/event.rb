require 'cikl/observables'
require 'cikl/base_model'
require 'equalizer'
module Cikl
  class Event < Cikl::BaseModel
    attribute :import_time, DateTime
    attribute :detect_time, DateTime
    attribute :source, String
    attribute :feed_provider, String
    attribute :feed_name, String
    attribute :tags, Array[String], default: lambda { |i, o| 
      [] 
    }
    attribute :event_id, String
    attribute :observables, Cikl::Observables, default: lambda { |i, o| 
      Cikl::Observables.new 
    }

    def to_serializable_hash
      ret = super
      ret[:observables] = self.observables.to_serializable_hash
      ret
    end

    include Equalizer.new(*attribute_set.map(&:name))
  end
end
