
RSpec.shared_examples_for 'an FQDN query endpoint' do
  include APIHelpers

  it_should_behave_like 'a proper API endpoint when matching 0 events' do
    before :each do
      query_proc.call('non-existent.fqdn-tests.com')
    end
  end

  shared_examples_for 'fqdn query endpoint examples' do |parent_fqdn, observable_type, observable_field|
    shared_examples 'our examples' do
      it_should_behave_like 'a proper API endpoint when matching 1 or more events'

      describe 'the result' do
        let(:result) { MultiJson.load(last_response.body) }
        subject { result }
        its(["count"]) { is_expected.to eq(4) }
        its(["total_events"]) { is_expected.to eq(4) }

        describe 'the events' do
          let(:events) { result['events'] }

          it "should include an event where #{observable_type}.#{observable_field} equals 'sub.#{parent_fqdn}'" do
            expect(events).to include(
              an_event_with_observable(observable_type, observable_field => "sub.#{parent_fqdn}"),
            )
          end
          it "should include an event where #{observable_type}.#{observable_field} equals 'deep1.sub.#{parent_fqdn}'" do
            expect(events).to include(
              an_event_with_observable(observable_type, observable_field => "deep1.sub.#{parent_fqdn}"),
            )
          end
          it "should include an event where #{observable_type}.#{observable_field} equals 'deep2.sub.#{parent_fqdn}'" do
            expect(events).to include(
              an_event_with_observable(observable_type, observable_field => "deep2.sub.#{parent_fqdn}"),
            )
          end
          it "should include an event where #{observable_type}.#{observable_field} equals 'really.really.really.deep.sub.#{parent_fqdn}'" do
            expect(events).to include(
              an_event_with_observable(observable_type, observable_field => "really.really.really.deep.sub.#{parent_fqdn}"),
            )
          end
        end
      end
    end

    describe "a query for the subdomain: sub.#{parent_fqdn}" do
      include_examples 'our examples'

      before :each do
        query_proc.call( "sub.#{parent_fqdn}" )
      end
    end

    context "querying the parent fqdn: #{parent_fqdn}" do
      include_context 'our examples'

      before :each do
        query_proc.call( parent_fqdn )
      end
    end

  end

  context 'matching against fqdn.fqdn' do
    include_examples 'fqdn query endpoint examples', 'fqdn.fqdn-tests.com', 'fqdn', 'fqdn'
  end

  context 'matching against dns_answer.name' do
    include_examples 'fqdn query endpoint examples', 'dns-name.fqdn-tests.com', 'dns_answer', 'name'
  end

  context 'matching against dns_answer.fqdn' do
    include_examples 'fqdn query endpoint examples', 'dns-fqdn.fqdn-tests.com', 'dns_answer', 'fqdn'
  end

end


