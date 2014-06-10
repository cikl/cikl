# encoding: utf-8
require 'rubygems'
require "logstash/outputs/base"
require "logstash/namespace"


class LogStash::Filters::CiklMongodb < LogStash::Filters::Base

  config_name "cikl_mongodb"
  milestone 1

  # a MongoDB URI to connect to
  # See http://docs.mongodb.org/manual/reference/connection-string/
  config :uri, :validate => :string, :required => true
  
  # The database to use
  config :database, :validate => :string, :required => true
   
  # Number of seconds to wait after failure before retrying
  config :retry_delay, :validate => :number, :default => 3, :required => false

  public
  def register
    require "mongo"
    uriParsed=Mongo::URIParser.new(@uri)
    conn = uriParsed.connection({})
    if uriParsed.auths.length > 0
      uriParsed.auths.each do |auth|
        if !auth['db_name'].nil?
          conn.add_auth(auth['db_name'], auth['username'], auth['password'], nil)
        end 
      end
      conn.apply_saved_authentication()
    end
    @db = conn.db(@database)
  end # def register

  public
  def filter(event)
    return unless filter?(event)
    return unless event['type'] == 'event'

    document = event.to_hash.dup
    parent_id = nil
    begin
      if parent_id = document['event_id']
        parent_id = BSON::ObjectId.from_string(parent_id)
      else 
        parent_id = BSON::ObjectId.new(nil, event["@timestamp"])
      end

      document['event_id'] = parent_id
      @db.collection("event").update(
        {:_id => parent_id},
        document,
        {
          :upsert => true
        }
      )
    rescue => e
      @logger.warn("Failed to send event to MongoDB", :event => event, :exception => e,
                   :backtrace => e.backtrace)
      sleep @retry_delay
      retry
    end
    parent_id_s = parent_id.to_s
    event["event_id"] = parent_id_s
  end # def receive
end # class LogStash::Outputs::CiklMongodb
