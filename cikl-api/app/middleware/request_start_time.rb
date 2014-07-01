require 'pp'
module Cikl
  module Middleware
    class RequestStartTime
      def initialize(app, opts = {})
        @app = app
      end 

      def call(env)
        env['REQUEST_START_TIME'] = Time.now
        @app.call(env)
      end
    end
  end
end


