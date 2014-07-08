RSpec.shared_examples_for 'an IPv4 query endpoint' do
  it_should_behave_like 'a proper API endpoint when matching 0 events' do
    before :each do
      query_proc.call('255.100.1.1')
    end
  end

  context "matching against ipv4.ipv4" do
    before :each do
      query_proc.call('100.1.1.1')
    end

    it_should_behave_like 'a proper API endpoint when matching 1 or more events'

    describe 'the response data' do
      let(:result) { MultiJson.load(last_response.body) }
      it "should only have the matching events" do
        expect(result['total_events']).to eq(1)
        expect(result['count']).to eq(1)
        expect(result['events'].length).to eq(1)
        event = result['events'].first

        expect(event['observables']).to eq(
          {
            'ipv4' => [
              {
                'ipv4' => '100.1.1.1'
              }
            ]
          }
        )
      end
    end

  end

  context "matching against dns_answer.ipv4" do
    before :each do
      query_proc.call('100.1.3.1')
    end

    it_should_behave_like 'a proper API endpoint when matching 1 or more events'

    describe 'the response data' do
      let(:result) { MultiJson.load(last_response.body) }
      it "should only have the matching events" do
        expect(result['total_events']).to eq(1)
        expect(result['count']).to eq(1)
        expect(result['events'].length).to eq(1)
        event = result['events'].first
        expect(event['observables'].count).to eq(1)
        dns_answer = event['observables']['dns_answer'][0]
        expect(dns_answer['ipv4']).to eq('100.1.3.1')
      end
    end
  end

  context "matching against ipv4.ipv4 and dns_answer.ipv4 at the same time" do
    before :each do
      query_proc.call('100.1.2.1')
    end

    it_should_behave_like 'a proper API endpoint when matching 1 or more events'

    describe 'the response data' do
      let(:result) { MultiJson.load(last_response.body) }
      it "should only have the matching events" do
        expect(result['total_events']).to eq(2)
        expect(result['count']).to eq(2)
        expect(result['events'].length).to eq(2)
        event1 = result['events'][0]
        event2 = result['events'][1]
        dns_answer = ipv4 = nil

        if event1['observables']['dns_answer']
          dns_answer = event1['observables']['dns_answer'][0]
          ipv4 = event2['observables']['ipv4'][0]
        else 
          dns_answer = event2['observables']['dns_answer'][0]
          ipv4 = event1['observables']['ipv4'][0]
        end
        expect(dns_answer['ipv4']).to eq('100.1.2.1')
        expect(ipv4['ipv4']).to eq('100.1.2.1')
      end
    end
  end
end
