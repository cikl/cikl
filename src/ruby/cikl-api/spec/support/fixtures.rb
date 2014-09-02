require 'elasticsearch'
require 'multi_json'
require 'fixtures/events'

module Fixtures
  class Loader
    def initialize
      @index_name = "#{Cikl::Config.elasticsearch_index}-#{DateTime.now.strftime('%Y.%m.%d')}"
      @bulk_es = []
    end

    private 
    def install_es_template
      template = MultiJson.load(File.read(Cikl::Config.elasticsearch_template_path))
      template["template"] = @index_name
      Cikl::ESClient.indices.put_template(name: "cikl_testing", body: template)
    end

    def insert_event(event_hash)
      if event_id = event_hash['event_id']
        event_id = BSON::ObjectId.from_string(event_id)
      else 
        event_id = BSON::ObjectId.new
      end
      event_id_s = event_id.to_s

      event_hash['_id'] = event_id
      event_hash['event_id'] = event_id_s
      @mongo_bulk.insert(event_hash)
      @bulk_es << { index: {_id: event_id_s, data: event_hash } }
    end
    
    def flush
      @mongo_bulk.execute()
      unless @bulk_es.empty?
        Cikl::ESClient.bulk index: @index_name, type: :event, body: @bulk_es
        @bulk_es.clear
      end
    end

    def load_fixtures
      @mongo_bulk = Cikl::MongoEventCollection.initialize_unordered_bulk_op
      orig_start = Time.now
      start = Time.now
      events = Fixtures.events
      generate_time = Time.now - start
      start = Time.now
      event_hashes = events.map { |e| Cikl::API::Entities::Event.represent(e, serializable: true) }
      convert_time = Time.now - start
      start = Time.now
      event_hashes.each do |eh|
        insert_event(eh)
      end
      flush
      insert_time = Time.now - start
      total = Time.now - orig_start
      generate_pct = ((generate_time / total) * 100).to_i
      convert_pct = ((convert_time / total) * 100).to_i
      insert_pct = ((insert_time / total) * 100).to_i
      rate = events.count / total
      warn "Loaded #{events.count} fixtures in #{total} seconds (#{rate} fixtures per second). generate: #{generate_pct}%, convert: #{convert_pct}%, insert: #{insert_pct}%"
      @mongo_bulk = nil
    end

    public

    def load!
      install_es_template
      load_fixtures
      # Refresh data
      Cikl::ESClient.indices.refresh()
    end

    def self.destroy!
      Cikl::Mongo.drop_database(Cikl::Mongo.db.name)
      Cikl::ESClient.indices.delete(index: Cikl::Config.elasticsearch_index_pattern)
    end
  end
end
