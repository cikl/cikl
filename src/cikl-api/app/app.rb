require 'api/root'
require 'middleware/request_start_time'
require 'rack/cors'

module Cikl
  class App
    def initialize()
    end

    def self.build
      Rack::Builder.new do
        use Cikl::Middleware::RequestStartTime

        use Rack::Cors do
          allow do
            origins '*'
            resource '*', 
              headers: :any, 
              methods: [:get, :post, :options]
          end
        end

        if ENV['RACK_ENV'] == 'development'
          map('/api/doc') do
            use Rack::Static,
              :urls => [""], 
              :root => File.expand_path('../../vendor/swagger-ui', __FILE__),
              :index => "index.html"
            run lambda {|*|}
          end
        end

        run Cikl::App.new
      end.to_app
    end

    def call(env)
      Cikl::API::Root.call(env)
    end
  end
end
