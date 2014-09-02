RSpec.shared_examples_for 'a json API response' do
  subject { response } 
  its(:content_type) { is_expected.to eq('application/json') }
end

