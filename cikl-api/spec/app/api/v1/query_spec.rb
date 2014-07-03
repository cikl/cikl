require 'spec_helper'
require 'rack/test'

describe 'Cikl API v1 :query endpoint' do
  include Rack::Test::Methods

  def app
    Cikl::App.build
  end

  it "returns stuff" do
    post '/api/v1/query/fqdn', {
      fqdn: 'google.com'
    }
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
  end
end
