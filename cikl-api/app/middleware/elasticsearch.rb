require 'elasticsearch'
require 'connection_pool'

module Cikl
  module Middleware
    class Elasticsearch
      def initialize(app, opts = {})
        @app = app
        @pool = ConnectionPool.new(size: 5, timeout: 10) do
          # TODO: make configurable.
          ::Elasticsearch::Client.new(log: false)
        end
        at_exit do
          @pool.shutdown do |es|
            # Don't do anything?
          end
        end
      end 

      def call(env)
        #env[:elasticsearch] = self.client
        @pool.with do |es|
          env['elasticsearch'] = es
          return @app.call(env)
        end
      end
    end
  end
end

