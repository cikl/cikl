
RSpec.shared_examples_for 'an FQDN query endpoint' do
  describe "a query for 'google.com'" do
    before :each do
      query_proc.call('google.com', import_time_min: '2000-01-01T00:00:00+00:00' )
    end

    describe 'the response' do
      let(:response) { last_response }
      it_should_behave_like 'a json API response'
    end
    describe 'the result hash' do
      let(:result) { MultiJson.load(last_response.body) }
      let(:events) { result['events'] }
      subject { result } 
      its(['total_events']) { is_expected.to eq(31) }
      its(['count']) { is_expected.to eq(31) }
      describe 'the events' do
        it "should have 1 event with an fqdn observable for 'google.com'" do
          fqdns = events.find_all { |e| e['observables'].has_key?('fqdn') && !(e['observables']['fqdn'].empty?) }
          expect(fqdns.count).to eq(1)
          expect(fqdns.first()['observables']['fqdn'][0]['fqdn']).to eq('google.com')
        end
        it "should have 30 events with an dns_answer observable" do
          count = events.count { |e| e['observables'].has_key?('dns_answer') && !(e['observables']['dns_answer'].empty?) }
          expect(count).to eq(30)
        end
      end
    end
  end

  describe "a query for 'l.google.com'" do
    before :each do
      query_proc.call('l.google.com', import_time_min: '2000-01-01T00:00:00+00:00' )
    end

    describe 'the response' do
      let(:response) { last_response }
      it_should_behave_like 'a json API response'
    end
    describe 'the result hash' do
      let(:result) { MultiJson.load(last_response.body) }
      let(:events) { result['events'] }
      subject { result } 
      its(['total_events']) { is_expected.to eq(10) }
      its(['count']) { is_expected.to eq(10) }
      describe 'the events' do
        it "should have no fqdn observables" do
          fqdns = events.find_all { |e| e['observables'].has_key?('fqdn') && !(e['observables']['fqdn'].empty?) }
          expect(fqdns.count).to eq(0)
        end
        it "should have 10 events with an dns_answer observable" do
          count = events.count { |e| e['observables'].has_key?('dns_answer') && !(e['observables']['dns_answer'].empty?) }
          expect(count).to eq(10)
        end
      end
    end
  end

  describe "a query for 'com'" do
    before :each do
      query_proc.call('com', import_time_min: '2000-01-01T00:00:00+00:00' )
    end

    describe 'the response' do
      let(:response) { last_response }
      it_should_behave_like 'a json API response'
    end
    describe 'the result hash' do
      let(:result) { MultiJson.load(last_response.body) }
      let(:events) { result['events'] }
      subject { result } 
      its(['total_events']) { is_expected.to eq(31) }
      its(['count']) { is_expected.to eq(31) }
    end
  end

  describe "a query for a name that doesn't exist ('thisdomaindoesnotexist.com')" do
    before :each do
      query_proc.call('thisdomaindoesnotexist.com', import_time_min: '2000-01-01T00:00:00+00:00' )
    end

    describe 'the response' do
      let(:response) { last_response }
      it_should_behave_like 'a json API response'
    end
    describe 'the result hash' do
      let(:result) { MultiJson.load(last_response.body) }
      subject { result } 
      its(['total_events']) { is_expected.to eq(0) }
      its(['count']) { is_expected.to eq(0) }
      its(['events']) { is_expected.to eq([]) }
    end
  end
end


