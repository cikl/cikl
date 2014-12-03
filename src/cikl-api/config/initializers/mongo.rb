require 'mongo'

module Cikl
  @@mongo = nil
  @@mongo_event_collection = nil
  def self.mongo_client
    if @@mongo == nil
      @@mongo = ::Mongo::MongoClient.from_uri(Cikl::Config.mongo_uri, :pool_size => 5)
    end
    @@mongo
  end

  def self.mongo_event_collection
    if @@mongo_event_collection == nil
      @@mongo_event_collection = self.mongo_client.db['event']
    end
    @@mongo_event_collection
  end
end
