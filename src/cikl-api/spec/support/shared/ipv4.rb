RSpec.shared_examples_for 'an IPv4 query endpoint' do
  include APIHelpers

  shared_examples_for 'ipv4 query endpoint examples' do |ipv4, observable_sets|
    it_should_behave_like 'a proper API endpoint when matching 1 or more events'

    describe "the result" do
      let(:result) { MultiJson.load(last_response.body) }
      subject { result }
      its(["count"]) { is_expected.to eq(observable_sets.count) }
      its(["total_events"]) { is_expected.to eq(observable_sets.count) }
      describe 'the events' do
        let(:events) { result['events'] }
        subject { events }
        its(:count) { is_expected.to eq(observable_sets.count) }
        observable_sets.each do |type, field|
          it "should include an event where #{type}.#{field} equals '#{ipv4}'" do
            expect(events).to include ( 
              an_event_with_observable(type, field => ipv4)
            )
          end
        end
      end
    end
  end

  it_should_behave_like 'a proper API endpoint when matching 0 events' do
    before :each do
      query_proc.call('255.100.1.1')
    end
  end

  context "matching against ipv4.ipv4 with a query for '100.1.1.1'" do
    include_examples 'ipv4 query endpoint examples', '100.1.1.1', [['ipv4', 'ipv4']]
    before :each do
      query_proc.call('100.1.1.1')
    end
  end

  context "matching against dns_answer.ipv4 with a query for '100.1.3.1'" do
    include_examples 'ipv4 query endpoint examples', '100.1.3.1', [['dns_answer', 'ipv4']]
    before :each do
      query_proc.call('100.1.3.1')
    end
  end

  context "matching against ipv4.ipv4 and dns_answer.ipv4 with a query for '100.1.2.1'" do
    before :each do
      query_proc.call('100.1.2.1')
    end

    include_examples 'ipv4 query endpoint examples', '100.1.2.1', [
      ['dns_answer', 'ipv4'],
      ['ipv4', 'ipv4']
    ]

  end
end
