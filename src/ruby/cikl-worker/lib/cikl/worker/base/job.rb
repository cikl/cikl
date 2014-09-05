require 'observer'

module Cikl
  module Worker
    module Base
      class Job
        include Observable

        STATE_INIT = 0
        STATE_STARTED = 1
        STATE_FINISHED = 100
        
        def initialize(opts = {})
          @on_finish_cb = opts[:on_finish]
          @state = STATE_INIT
        end

        def start!
          @state = STATE_STARTED
          changed
          notify_observers(:job_start, self)
        end

        def started?
          @state >= STATE_STARTED
        end

        def finished?
          @state >= STATE_FINISHED
        end

        def finish!(result)
          @on_finish_cb.call(self, result) unless @on_finish_cb.nil?
          @state = STATE_FINISHED
          changed
          notify_observers(:job_finish, self, result)
        end
      end
    end
  end
end

