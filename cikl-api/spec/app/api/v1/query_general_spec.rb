require 'spec_helper'

describe 'Cikl API v1 query', :integration, :app do

  describe 'a default query' do
    before :each do
      post '/api/v1/query/fqdn', {fqdn: 'import-time-tests.com'}
    end
    it_should_behave_like 'a proper API endpoint when matching 1 or more events'

    let(:result) { MultiJson.load(last_response.body) }
    let(:query) { result['query'] }
    describe 'the returned query parameters' do
      subject { query }
      it { is_expected.to match(
          {
            "start" => 1,
            "per_page" => 50,
            "order_by" => "import_time",
            "order" => "desc",
            "timing" => 0,
            "import_time_max" => nil,
            "detect_time_min" => nil,
            "detect_time_max" => nil,
            "import_time_min" => a_kind_of(::String),
          }
        )
      }

      describe 'import_time_min' do
        subject { DateTime.parse(query['import_time_min']).to_time }
        it { is_expected.to be_within(10).of((DateTime.now - 30).to_time) }
      end
    end
  end

end
