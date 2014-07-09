require 'rack/test'

RSpec.shared_context 'for apps', :app do
  include Rack::Test::Methods

  def app
    Cikl::App.build
  end
end
