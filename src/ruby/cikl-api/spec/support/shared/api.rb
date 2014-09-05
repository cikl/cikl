RSpec.shared_examples_for 'a proper API endpoint when matching 1 or more events' do
  describe 'the HTTP response' do
    let(:response) { last_response }
    it_should_behave_like 'a json API response'
  end

  describe 'the response data' do
    let(:response_data) { MultiJson.load(last_response.body) }
    subject { response_data }
    its(['total_events']) { is_expected.to be > 0 }
    its(['count']) { is_expected.to be > 0 }
    its(['events']) { is_expected.not_to eq([]) }
  end
end

RSpec.shared_examples_for 'a proper API endpoint when matching 0 events' do
  before :each do
    query_proc.call('255.100.100.1')
  end

  describe 'the HTTP response' do
    let(:response) { last_response }
    it_should_behave_like 'a json API response'
  end

  describe 'the response data' do
    let(:response_data) { MultiJson.load(last_response.body) }
    subject { response_data }
    its(['total_events']) { is_expected.to eq(0) }
    its(['count']) { is_expected.to eq(0) }
    its(['events']) { is_expected.to eq([]) }
  end
end

