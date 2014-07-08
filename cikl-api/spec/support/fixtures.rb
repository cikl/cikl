require 'elasticsearch'
require 'models/event'
require 'yaml'
require 'multi_json'
require 'fixtures/events'

module Fixtures
  module Loader
    private 
    def self.index_name
      @index_name ||= "#{Cikl::Config.elasticsearch_index}-#{DateTime.now.strftime('%Y.%m.%d')}"
    end

    def self.install_es_template
      template = MultiJson.load(File.read(Cikl::Config.elasticsearch_template_path))
      template["template"] = index_name
      Cikl::ESClient.indices.put_template(name: "cikl_testing", body: template)
    end

    def self.insert_event(event)
      event_hash = Cikl::API::Entities::Event.represent(event, :serializable => true)

      if event_id = event_hash['event_id']
        event_id = BSON::ObjectId.from_string(event_id)
      else 
        event_id = BSON::ObjectId.new
      end

      event_hash['_id'] = event_id
      event_hash['event_id'] = event_id
      #
      # Insert into mongodb.
      Cikl::MongoEventCollection.update(
        {:_id => event_id },
        event_hash,
        {
          :upsert => true
        }
      )

      event_hash['event_id'] = event_id.to_s

      Cikl::ESClient.index(
        index: index_name,
        type: 'event',
        body: event_hash
      )
    end

    def self.load_from_yaml
      filename = File.expand_path('../../fixtures/events.yaml', __FILE__)
      File.open(filename, 'r') do |fio|
        YAML.load_documents(fio) do |event_hash|
          model = Cikl::Models::Event.from_hash(event_hash)
          insert_event(model)
        end
      end
    end

    def self.load_fixtures
      Fixtures.events.each do |event|
        insert_event(event)
      end
    end

    public

    def self.load!
      install_es_template
      load_from_yaml
      #load_fixtures
      # Refresh data
      Cikl::ESClient.indices.refresh()
    end

    def self.destroy!
      Cikl::Mongo.drop_database(Cikl::Mongo.db.name)
      Cikl::ESClient.indices.delete(index: Cikl::Config.elasticsearch_index_pattern)
    end
  end
end
