
module Cikl
  module Worker
    module Exceptions
      # Indicates an error occurred while building the job
      class JobBuildError < StandardError
      end

      class AMQPError < StandardError
      end

      class AMQPConnectionFailed < AMQPError
      end

      class AMQPNotStarted < AMQPError
      end

      class AMQPAlreadyStarted < AMQPError
      end
    end
  end
end
