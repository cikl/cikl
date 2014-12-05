module Cikl
  module Worker
    module Base
      module JobResultHandler
        # processes a job result
        # @param [Cikl::Worker::Base::JobResult] job_result
        def handle_job_result(job_result)
          #:nocov:
          raise NotImplementedError.new
          #:nocov:
        end
      end
    end
  end
end

