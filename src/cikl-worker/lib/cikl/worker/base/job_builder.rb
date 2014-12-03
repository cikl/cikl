module Cikl
  module Worker
    module Base
      # Builds jobs.
      class JobBuilder
        # @param [String] payload A string payload that contains data a job
        # @param [Hash] opts Options to pass to the job instance.
        # @return job [Cikl::Worker::Base::Job] A job
        def build(payload, opts = {})
          #:nocov:
          raise NotImplementedError.new
          #:nocov:
        end
      end
    end
  end
end
