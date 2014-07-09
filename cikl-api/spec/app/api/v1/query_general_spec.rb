require 'spec_helper'

describe 'Cikl API v1 query', :integration, :app do
  include APIHelpers

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

  describe "filtering by import_time" do
    it "should find all events within the last 30 days by default" do
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {fqdn: 'import-time-tests.com'}
      end
      result = MultiJson.load(last_response.body)
      expect(result["events"]).to match(
        a_collection_containing_exactly(
          an_event_with_observable('fqdn', 'fqdn' => '0.import-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '1.import-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '7.import-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '29.import-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '30.import-time-tests.com')
        )
      )
    end

    describe :import_time_min do
      it "should include events with an import_time greater than or equal to the time specified" do
        seven_days_ago = Fixtures.now - 7
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', {
            fqdn: 'import-time-tests.com', 
            import_time_min: seven_days_ago.to_s
          }
        end
        result = MultiJson.load(last_response.body)

        expect(result["events"]).to match(
          a_collection_containing_exactly(
            an_event_with_observable('fqdn', 'fqdn' => '0.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '7.import-time-tests.com')
          )
        )
      end

      it "should have 1 second precision" do
        one_second = 1.0 / (24 * 60 * 60)
        seven_days_ago = (Fixtures.now - 7)
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', {
            fqdn: 'import-time-tests.com', 
            import_time_min: (seven_days_ago + one_second)
          }
        end
        result = MultiJson.load(last_response.body)

        expect(result["events"]).to match(
          a_collection_containing_exactly(
            an_event_with_observable('fqdn', 'fqdn' => '0.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.import-time-tests.com'),
          )
        )
      end

      it "should return all events when set to nil" do
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query', {
            fqdn: 'import-time-tests.com', 
            import_time_min: nil
          }
        end
        result = MultiJson.load(last_response.body)

        expect(result["events"]).to match(
          a_collection_containing_exactly(
            an_event_with_observable('fqdn', 'fqdn' => '0.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '7.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '29.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '30.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '31.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '60.import-time-tests.com')
          )
        )
      end
    end

    describe :import_time_max do
      it "should include events with an import_time less than or equal to the time specified" do
        seven_days_ago = Fixtures.now - 7
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', {
            fqdn: 'import-time-tests.com', 
            import_time_max: seven_days_ago.to_s
          }
        end
        result = MultiJson.load(last_response.body)

        expect(result["events"]).to match(
          a_collection_containing_exactly(
            an_event_with_observable('fqdn', 'fqdn' => '7.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '29.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '30.import-time-tests.com')
          )
        )
      end

      it "should have 1 second precision" do
        one_second = 1.0 / (24 * 60 * 60)
        seven_days_ago = (Fixtures.now - 7)
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', {
            fqdn: 'import-time-tests.com', 
            import_time_max: (seven_days_ago - one_second)
          }
        end
        result = MultiJson.load(last_response.body)

        expect(result["events"]).to match(
          a_collection_containing_exactly(
            an_event_with_observable('fqdn', 'fqdn' => '29.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '30.import-time-tests.com'),
          )
        )
      end
    end
  end

  describe "order_by: 'import_time'" do
    let(:query) { 
      {
        fqdn: 'import-time-tests.com',
        order_by: 'import_time'
      } 
    }

    shared_examples_for "descending order" do
      before :each do
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', query
        end
      end
      specify 'the events should be in descending order' do
        result = MultiJson.load(last_response.body)
        expect(result["events"]).to match(
          [
            an_event_with_observable('fqdn', 'fqdn' => '0.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '7.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '29.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '30.import-time-tests.com')
          ]
        )
      end
    end

    describe 'by default' do
      it_should_behave_like "descending order"
    end

    describe "order: 'desc'" do
      before :each do
        query[:order] = 'desc'
      end
      it_should_behave_like "descending order"
    end

    describe "order: 'asc'" do
      before :each do
        query[:order] = 'asc'
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', query
        end
      end
      specify 'the events should be in ascending order' do
        result = MultiJson.load(last_response.body)
        expect(result["events"]).to match(
          [
            an_event_with_observable('fqdn', 'fqdn' => '30.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '29.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '7.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.import-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '0.import-time-tests.com')
          ]
        )
      end
    end
  end

  describe "order_by: 'detect_time'" do
    let(:query) { 
      {
        fqdn: 'detect-time-tests.com',
        order_by: 'detect_time'
      } 
    }

    shared_examples_for "descending order" do
      before :each do
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', query
        end
      end
      specify 'the events should be in descending order, but with null entries after everything else' do
        result = MultiJson.load(last_response.body)
        expect(result["events"]).to match(
          [
            an_event_with_observable('fqdn', 'fqdn' => '0.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '7.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '29.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '30.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '31.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '60.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => 'nil.detect-time-tests.com')
          ]
        )
      end
    end

    describe 'by default' do
      it_should_behave_like "descending order"
    end

    describe "order: 'desc'" do
      before :each do
        query[:order] = 'desc'
      end
      it_should_behave_like "descending order"
    end

    describe "order: 'asc'" do
      before :each do
        query[:order] = 'asc'
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query/fqdn', query
        end
      end
      specify 'the events should be in ascending order, but with null entries after everything else' do
        result = MultiJson.load(last_response.body)
        expect(result["events"]).to match(
          [
            an_event_with_observable('fqdn', 'fqdn' => '60.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '31.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '30.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '29.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '7.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '1.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => '0.detect-time-tests.com'),
            an_event_with_observable('fqdn', 'fqdn' => 'nil.detect-time-tests.com')
          ]
        )
      end
    end
  end

  describe "not specifying detect_time_min or detect_time_max" do
    it "should include any event with or without a detect_time" do
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com'
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).to match(
        a_collection_containing_exactly(
          an_event_with_observable('fqdn', 'fqdn' => 'nil.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '0.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '1.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '7.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '29.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '30.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '31.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '60.detect-time-tests.com')
        )
      )
    end
  end

  describe :detect_time_max do
    it "should include events with an detect_time less than or equal to the time specified" do
      seven_days_ago = Fixtures.now - 7
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com', 
          detect_time_max: seven_days_ago.to_s
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).to match(
        a_collection_containing_exactly(
          an_event_with_observable('fqdn', 'fqdn' => '7.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '29.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '30.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '31.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '60.detect-time-tests.com')
        )
      )
    end

    it "should not include any events with an null detect_time when detect_time_max is set" do
      seven_days_ago = Fixtures.now - 7
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com', 
          detect_time_max: seven_days_ago.to_s
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).not_to match(
        a_collection_including(
          an_event_with_observable('fqdn', 'fqdn' => 'nil.detect-time-tests.com'),
        )
      )
    end

    it "should have 1 second precision" do
      one_second = 1.0 / (24 * 60 * 60)
      seven_days_ago = (Fixtures.now - 7)
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com', 
          detect_time_max: (seven_days_ago - one_second)
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).to match(
        a_collection_containing_exactly(
          an_event_with_observable('fqdn', 'fqdn' => '29.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '30.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '31.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '60.detect-time-tests.com')
        )
      )
    end
  end

  describe :detect_time_min do
    it "should include events with an detect_time greater than or equal to the time specified" do
      seven_days_ago = Fixtures.now - 7
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com', 
          detect_time_min: seven_days_ago.to_s
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).to match(
        a_collection_containing_exactly(
          an_event_with_observable('fqdn', 'fqdn' => '0.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '1.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '7.detect-time-tests.com')
        )
      )
    end

    it "should not include any events with an null detect_time when detect_time_min is set" do
      seven_days_ago = Fixtures.now - 7
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com', 
          detect_time_min: seven_days_ago.to_s
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).not_to match(
        a_collection_including(
          an_event_with_observable('fqdn', 'fqdn' => 'nil.detect-time-tests.com'),
        )
      )
    end

    it "should have 1 second precision" do
      one_second = 1.0 / (24 * 60 * 60)
      seven_days_ago = (Fixtures.now - 7)
      Timecop.freeze(Fixtures.now) do
        post '/api/v1/query/fqdn', {
          fqdn: 'detect-time-tests.com', 
          detect_time_min: (seven_days_ago + one_second)
        }
      end
      result = MultiJson.load(last_response.body)

      expect(result["events"]).to match(
        a_collection_containing_exactly(
          an_event_with_observable('fqdn', 'fqdn' => '0.detect-time-tests.com'),
          an_event_with_observable('fqdn', 'fqdn' => '1.detect-time-tests.com')
        )
      )
    end
  end
end
