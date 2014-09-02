require 'virtus'

module Cikl
  module Models
    class Timing
      include Virtus.model
      attribute :request_start, Time
      attribute :query_start, Time
      attribute :elasticsearch_start, Time
      attribute :elasticsearch_finish, Time
      attribute :backend_start, Time
      attribute :backend_finish, Time
      attribute :elasticsearch_internal_query

      def query_total_seconds
        backend_finish - query_start
      end

      def query_total_milliseconds
        (query_total_seconds * 1000).to_i
      end

      def pre_query_seconds
        query_start - request_start
      end

      def pre_query_milliseconds
        (pre_query_seconds * 1000).to_i
      end

      def elasticsearch_total_seconds
        elasticsearch_finish - elasticsearch_start
      end

      def elasticsearch_total_milliseconds
        (elasticsearch_total_seconds * 1000).to_i
      end

      def backend_total_seconds
        backend_finish - backend_start
      end

      def backend_total_milliseconds
        (backend_total_seconds * 1000).to_i
      end
    end
  end
end


