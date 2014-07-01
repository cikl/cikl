require 'mongo'

module Cikl
  module Middleware
    class Mongo
      def initialize(app, opts = {})
        @app = app
        @client = ::Mongo::MongoClient.new(:pool_size => 5)
        @cikl_db = @client["cikl"]
        @event_collection = @cikl_db["event"]
        @cache = {}
        at_exit do
          @client.close
        end
      end 

      def call(env)
        env['mongo'] = @client
        env['mongo_event'] = @event_collection
        return @app.call(env)
      end
    end
  end
end


