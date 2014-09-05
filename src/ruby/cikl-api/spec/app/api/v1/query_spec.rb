require 'spec_helper'

describe 'Cikl API v1 query endpoint', :integration, :app do
  describe "querying by fqdn" do
    let(:query_proc) { 
      lambda do |fqdn, opts = {} |
      query_opts = opts.merge({ fqdn: fqdn })
      post '/api/v1/query', query_opts
    end
    }

    it_should_behave_like 'an FQDN query endpoint'
  end

  describe "querying by ipv4" do
    let(:query_proc) { 
      lambda do |ipv4, opts = {} |
      query_opts = opts.merge({ ipv4: ipv4 })
      post '/api/v1/query', query_opts
    end
    }

    it_should_behave_like 'an IPv4 query endpoint'
  end

  describe 'with no parameters' do
    before :each do
      post '/api/v1/query'
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
            "ipv4" => nil,
            "fqdn" => nil,
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
        post '/api/v1/query', {fqdn: 'import-time-tests.com'}
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
          post '/api/v1/query', {
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
          post '/api/v1/query', {
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
          post '/api/v1/query', {
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
          post '/api/v1/query', {
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
          post '/api/v1/query', query
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
          post '/api/v1/query', query
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
          post '/api/v1/query', query
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
          post '/api/v1/query', query
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
        post '/api/v1/query', {
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
        post '/api/v1/query', {
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
        post '/api/v1/query', {
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
        post '/api/v1/query', {
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
        post '/api/v1/query', {
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
        post '/api/v1/query', {
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
        post '/api/v1/query', {
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

  describe :facets do
    describe :min_detect_time do
      it "should contain the earliest detect_time" do
        post '/api/v1/query', { fqdn: 'detect-time-tests.com', }
        result = MultiJson.load(last_response.body)
        min_detect_time = result["facets"]["min_detect_time"]
        expect(min_detect_time).to eq((Fixtures.now - 60).iso8601)
      end

      it "should be null if there are no detect times" do
        post '/api/v1/query', { fqdn: 'import-time-tests.com', }
        result = MultiJson.load(last_response.body)
        expect(result["facets"]["min_detect_time"]).to be_nil
      end

      it "should be null if there are no events" do
        post '/api/v1/query', { fqdn: 'non-existent-domain.com' }
        result = MultiJson.load(last_response.body)
        expect(result["count"]).to eq(0)
        min_detect_time = result["facets"]["min_detect_time"]
        expect(min_detect_time).to be_nil
      end
    end

    describe :max_detect_time do
      it "should contain the latest detect_time" do
        post '/api/v1/query', { fqdn: 'detect-time-tests.com', }
        result = MultiJson.load(last_response.body)
        max_detect_time = result["facets"]["max_detect_time"]
        expect(max_detect_time).to eq(Fixtures.now.iso8601)
      end

      it "should be null if there are no events" do
        post '/api/v1/query', { fqdn: 'non-existent-domain.com', }
        result = MultiJson.load(last_response.body)
        expect(result["count"]).to eq(0)
        max_detect_time = result["facets"]["max_detect_time"]
        expect(max_detect_time).to be_nil
      end
    end

    describe :min_import_time do
      it "should contain the earliest import_time" do
        Timecop.freeze(Fixtures.now) do
          post '/api/v1/query', { fqdn: 'import-time-tests.com', }
        end
        result = MultiJson.load(last_response.body)
        min_import_time = result["facets"]["min_import_time"]
        expect(min_import_time).to eq((Fixtures.now - 30).iso8601)
      end

      it "should be null if there are no events" do
        post '/api/v1/query', { fqdn: 'non-existent-domain.com', }
        result = MultiJson.load(last_response.body)
        expect(result["count"]).to eq(0)
        min_import_time = result["facets"]["min_import_time"]
        expect(min_import_time).to be_nil
      end
    end

    describe :max_import_time do
      it "should contain the latest import_time" do
        post '/api/v1/query', { fqdn: 'import-time-tests.com', }
        result = MultiJson.load(last_response.body)
        max_import_time = result["facets"]["max_import_time"]
        expect(max_import_time).to eq(Fixtures.now.iso8601)
      end

      it "should be null if there are no events" do
        post '/api/v1/query', { fqdn: 'non-existent-domain.com', }
        result = MultiJson.load(last_response.body)
        expect(result["count"]).to eq(0)
        max_import_time = result["facets"]["max_import_time"]
        expect(max_import_time).to be_nil
      end
    end

    describe :sources do
      it "should contain the top 20 sources grouped by the number of events" do
        post '/api/v1/query', { fqdn: 'source-tests.com' }
        result = MultiJson.load(last_response.body)
        sources = result["facets"]["sources"]
        expect(sources.length).to eq(20)
        expect(sources[0..4]).to match(a_collection_containing_exactly(
          ['source_test_25', 5],
          ['source_test_24', 5],
          ['source_test_23', 5],
          ['source_test_22', 5],
          ['source_test_21', 5],
        ))
        expect(sources[5..9]).to match(a_collection_containing_exactly(
          ['source_test_20', 4],
          ['source_test_19', 4],
          ['source_test_18', 4],
          ['source_test_17', 4],
          ['source_test_16', 4],
        ))
        expect(sources[10..14]).to match(a_collection_containing_exactly(
          ['source_test_15', 3],
          ['source_test_14', 3],
          ['source_test_13', 3],
          ['source_test_12', 3],
          ['source_test_11', 3],
        ))
        expect(sources[15..19]).to match(a_collection_containing_exactly(
          ['source_test_10', 2],
          ['source_test_9', 2],
          ['source_test_8', 2],
          ['source_test_7', 2],
          ['source_test_6', 2],
        ))
      end
    end

    describe :feed_providers do
      it "should contain the top 20 feed_providers grouped by the number of events" do
        post '/api/v1/query', { fqdn: 'feed-provider-tests.com' }
        result = MultiJson.load(last_response.body)
        feed_providers = result["facets"]["feed_providers"]
        expect(feed_providers.length).to eq(20)
        expect(feed_providers[0..4]).to match(a_collection_containing_exactly(
          ['feed_provider_test_25', 5],
          ['feed_provider_test_24', 5],
          ['feed_provider_test_23', 5],
          ['feed_provider_test_22', 5],
          ['feed_provider_test_21', 5],
        ))
        expect(feed_providers[5..9]).to match(a_collection_containing_exactly(
          ['feed_provider_test_20', 4],
          ['feed_provider_test_19', 4],
          ['feed_provider_test_18', 4],
          ['feed_provider_test_17', 4],
          ['feed_provider_test_16', 4],
        ))
        expect(feed_providers[10..14]).to match(a_collection_containing_exactly(
          ['feed_provider_test_15', 3],
          ['feed_provider_test_14', 3],
          ['feed_provider_test_13', 3],
          ['feed_provider_test_12', 3],
          ['feed_provider_test_11', 3],
        ))
        expect(feed_providers[15..19]).to match(a_collection_containing_exactly(
          ['feed_provider_test_10', 2],
          ['feed_provider_test_9', 2],
          ['feed_provider_test_8', 2],
          ['feed_provider_test_7', 2],
          ['feed_provider_test_6', 2],
        ))
      end
    end

    describe :feed_names do
      it "should contain the top 20 feed_names grouped by the number of events" do
        post '/api/v1/query', { fqdn: 'feed-name-tests.com' }
        result = MultiJson.load(last_response.body)
        feed_names = result["facets"]["feed_names"]
        expect(feed_names.length).to eq(20)
        expect(feed_names[0..4]).to match(a_collection_containing_exactly(
          ['feed_name_test_25', 5],
          ['feed_name_test_24', 5],
          ['feed_name_test_23', 5],
          ['feed_name_test_22', 5],
          ['feed_name_test_21', 5],
        ))
        expect(feed_names[5..9]).to match(a_collection_containing_exactly(
          ['feed_name_test_20', 4],
          ['feed_name_test_19', 4],
          ['feed_name_test_18', 4],
          ['feed_name_test_17', 4],
          ['feed_name_test_16', 4],
        ))
        expect(feed_names[10..14]).to match(a_collection_containing_exactly(
          ['feed_name_test_15', 3],
          ['feed_name_test_14', 3],
          ['feed_name_test_13', 3],
          ['feed_name_test_12', 3],
          ['feed_name_test_11', 3],
        ))
        expect(feed_names[15..19]).to match(a_collection_containing_exactly(
          ['feed_name_test_10', 2],
          ['feed_name_test_9', 2],
          ['feed_name_test_8', 2],
          ['feed_name_test_7', 2],
          ['feed_name_test_6', 2],
        ))
      end
    end
  end
end
