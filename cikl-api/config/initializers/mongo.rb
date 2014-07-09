require 'mongo'

module Cikl
  Mongo = ::Mongo::MongoClient.from_uri(Cikl::Config.mongo_uri, :pool_size => 5)
  MongoEventCollection = Mongo.db['event']
end
