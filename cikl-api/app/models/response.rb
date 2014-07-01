require 'virtus'
require 'models/event'
require 'models/query_params'
require 'models/timing'

module Cikl
  module Models
    class Response
      include Virtus.model
      attribute :events, Array[Cikl::Models::Event], default: lambda { |r, a| [] }
      attribute :total_events, Integer
      attribute :timing, Cikl::Models::Timing
      attribute :query, Cikl::Models::QueryParams
    end
  end
end

