require 'date'

module Cikl
  module Worker
    module Base
      class JobResultPayload
        attr_reader :worker_name, :time
        def initialize()
          @worker_name = nil
          @time = nil
        end
        # @return [Hash] a hash version of the payload.
        def to_hash
          ret = {}
          ret[:source] = "cikl-worker"
          ret[:@timestamp] = @time.iso8601 unless @time.nil?
          ret
        end

        def stamp(worker_name, datetime)
          @worker_name = worker_name
          @time = datetime.to_datetime
        end

        def ==(other)
          # :nocov:
          raise NotImplementedError.new
          # :nocov:
        end
      end
    end
  end
end
