require 'spec_helper'
require 'api/validators/in_range'

describe Cikl::API::Validators::InRange do 
  module APIHelperSpec
    module InRangeSpec
      class API < Grape::API
        default_format :json

        params do
          requires :val, type: Integer, in_range: 5..20
        end
        get do

        end
      end
    end
  end

  def app
    APIHelperSpec::InRangeSpec::API
  end

  it 'refuses values that are before the range' do
    get '/', val: 4
    expect(last_response.status).to be(400)
  end

  it 'refuses values that are after the range' do
    get '/', val: 21
    expect(last_response.status).to be(400)
  end

  it 'accepts values at the start of the range' do
    get '/', val: 5
    expect(last_response.status).to be(200)
  end
  it 'accepts values at the end of the range' do
    get '/', val: 20
    expect(last_response.status).to be(200)
  end
  it 'accepts values in the range' do
    get '/', val: 10
    expect(last_response.status).to be(200)
  end
end
