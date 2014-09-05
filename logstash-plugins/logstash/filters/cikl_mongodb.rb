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
    existing_id = document['event_id']
    doc_id = nil
    begin
      unless existing_id.nil?
        doc_id = BSON::ObjectId.from_string(existing_id)
      else 
        doc_id = BSON::ObjectId.new(nil, event["@timestamp"])
      end

      document['_id'] = doc_id
      document['event_id'] = doc_id
      @db.collection("event").update(
        {:_id => doc_id },
        document,
        {
          :upsert => true
        }
      )

      #@db.collection("event").insert(document)
    rescue => e
      @logger.warn("Failed to send event to MongoDB", :event => event, :exception => e,
                   :backtrace => e.backtrace)
      sleep @retry_delay
      retry
    end
    event["event_id"] = doc_id.to_s if existing_id.nil?
  end # def receive
end # class LogStash::Outputs::CiklMongodb
