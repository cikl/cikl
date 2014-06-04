# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# Generates DNS query jobs from FQDN observables
#
# For example, to cancel 90% of events, you can do this:
#
#     filter {
#       generate_dns_queries { }
#     } 
#
class LogStash::Filters::GenerateDnsQueries < LogStash::Filters::Base
  config_name "generate_dns_queries"
  milestone 1

  public
  def register
  end # def register

  public
  def filter(event)
    return unless filter?(event)
    return unless event['type'] == 'event'
    return if event['observables'].nil?
    return if event['observables']['fqdn'].nil?
    event['observables']['fqdn'].each do |fqdn_observable|
      fqdn = fqdn_observable['fqdn']
      next unless fqdn
      new_event = LogStash::Event.new({
        'fqdn' => fqdn,
        'type' => 'do_dns_query'
      })
      filter_matched(new_event)
      yield new_event
    end

    filter_matched(event)
  end # def filter
end # class LogStash::Filters::GenerateDnsQueries
