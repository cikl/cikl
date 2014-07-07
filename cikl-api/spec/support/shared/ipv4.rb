
RSpec.shared_examples_for 'an IPv4 query endpoint' do
  describe "a query for '173.194.67.26'" do
    before :each do
      query_proc.call('173.194.67.26', import_time_min: '2000-01-01T00:00:00+00:00' )
    end

    describe 'the response' do
      let(:response) { last_response }
      it_should_behave_like 'a json API response'
    end
    describe 'the result hash' do
      let(:result) { MultiJson.load(last_response.body) }
      let(:events) { result['events'] }
      subject { result } 
      its(['total_events']) { is_expected.to eq(1) }
      its(['count']) { is_expected.to eq(1) }
      describe 'the events' do
        it "should have 1 event with an dns_answer observable for '173.194.67.26'" do
          dns_answers = events.find_all { |e| e['observables'].has_key?('dns_answer') && !(e['observables']['dns_answer'].empty?) }
          expect(dns_answers.count).to eq(1)
          dns_answer = dns_answers.first()['observables']['dns_answer'][0]
          expect(dns_answer['ipv4']).to eq('173.194.67.26')
        end
      end
    end
  end
end



