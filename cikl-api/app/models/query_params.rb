require 'virtus'
require 'date'

module Cikl
  module Models
    class QueryParams
      include Virtus.model
      attribute :start, Integer
      attribute :per_page, Integer
      attribute :assessment, String
      attribute :order_by, Symbol
      attribute :order, Symbol
      attribute :timing, Integer
      attribute :import_time_min, DateTime
      attribute :import_time_max, DateTime
      attribute :detect_time_min, DateTime
      attribute :detect_time_max, DateTime

      attribute :ipv4, String
      attribute :fqdn, String
    end
  end
end


