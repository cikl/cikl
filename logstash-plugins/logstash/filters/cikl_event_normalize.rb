# encoding: utf-8
require 'rubygems'
require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::CiklEventNormalize < LogStash::Filters::Base
  config_name "cikl_event_normalize"
  milestone 1

  public
  def register
  end

  def filter(event)
    return unless filter?(event)
    return unless event['type'] == 'event'

    if event['import_time'].nil?
      event['import_time'] = Time.now 
    end

    if event['detect_time'].nil?
      # Ensure that it's present and actually nil
      event['detect_time'] = nil
    end
    filter_matched(event)
  end # def filter
end # class LogStash::Outputs::CiklEventNormalize

