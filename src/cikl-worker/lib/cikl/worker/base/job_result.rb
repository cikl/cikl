module Cikl
  module Worker
    module Base
      module JobResult
        # @return [Array<Cikl::Worker::Base::JobResultPayload>] returns an array of payloads
        def payloads
          #:nocov:
          raise NotImplementedError.new
          #:nocov:
        end
      end
    end
  end
end
