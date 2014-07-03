require 'virtus'
require 'models/observables'
module Cikl
  module Models
    class Event
      include Virtus.model
      attribute :import_time, DateTime
      attribute :detect_time, DateTime
      attribute :source, String
      attribute :event_id, String
      attribute :observables, Cikl::Models::Observables, default: lambda { |i, o| Cikl::Models::Observables.new }

      class << self
        alias_method :from_hash, :new
      end
    end
  end
end
