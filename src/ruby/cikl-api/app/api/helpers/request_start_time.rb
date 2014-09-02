module Cikl
  module API
    module Helpers
      module RequestStartTime
        def get_request_start_time
          env['REQUEST_START_TIME']
        end
      end
    end
  end
end




