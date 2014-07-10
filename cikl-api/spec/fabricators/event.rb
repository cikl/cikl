require 'fabrication'
require 'models/event'
require 'date'
require 'bson'
Fabricator(:event, class_name: Cikl::Models::Event) do
  source          "generated"
  feed_provider   "test_provider"
  feed_name       "test_feed_name"
  import_time     { |attrs| DateTime.now }
  # 10 days ago
  #detect_time     { |attrs| DateTime.now - 10 }
  event_id        { |attrs| BSON::ObjectId.new().to_s }
  observables     fabricator: :observables
end

Fabricator(:observables, class_name: Cikl::Models::Observables) do
end


Fabricator(:ipv4, class_name: Cikl::Models::Observable::Ipv4) do
  ipv4    '127.0.0.1'
end

Fabricator(:fqdn, class_name: Cikl::Models::Observable::Fqdn) do
  fqdn    'fqdn.somedomain.com'
end

Fabricator(:dns_answer, class_name: Cikl::Models::Observable::DnsAnswer) do
  resolver 'cikl'
  rr_class 'IN'
  section  'answer'
end

Fabricator(:dns_answer_a, from: :dns_answer) do
  rr_type 'A'
  name    'dns_a.somedomain.com'
  ipv4    '127.0.0.1'
end

Fabricator(:dns_answer_ns, from: :dns_answer) do
  rr_type 'NS'
  name    'dns_ns.somedomain.com'
  fqdn    'ns1.somedomain.com'
end
