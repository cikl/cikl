require 'elasticsearch'
require 'models/event'
require 'yaml'
require 'multi_json'

module CiklSpec
  module Fixtures
    def self.load!
      filename = File.expand_path('../../fixtures/events.yaml', __FILE__)
      index_name = "#{Cikl::Config.elasticsearch_index}-#{DateTime.now.strftime('%Y.%m.%d')}"
      template = MultiJson.load(File.read(Cikl::Config.elasticsearch_template_path))
      template["template"] = index_name
      Cikl::ESClient.indices.put_template(name: "cikl_testing", body: template)
      File.open(filename, 'r') do |fio|
        YAML.load_documents(fio) do |event_hash|
          model = Cikl::Models::Event.from_hash(event_hash)
          event_hash = Cikl::API::Entities::Event.represent(model, :serializable => true)

          # Insert into mongodb.
          if event_id = event_hash['event_id']
            event_id = BSON::ObjectId.from_string(event_id)
          else 
            event_id = BSON::ObjectId.new
          end
          event_hash['event_id'] = event_id
          Cikl::MongoEventCollection.insert(event_hash)
          event_hash['event_id'] = event_id.to_s

          Cikl::ESClient.index(
            index: index_name,
            type: 'event',
            body: event_hash
          )
        end
      end
    end

    def self.destroy!
      Cikl::Mongo.drop_database(Cikl::Mongo.db.name)
      Cikl::ESClient.indices.delete(index: Cikl::Config.elasticsearch_index_pattern)
    end
  end
end
