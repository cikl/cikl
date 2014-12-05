require 'spec_helper'
require 'cikl/worker/dns/job_builder'
require 'shared_examples/job_builder'

describe Cikl::Worker::DNS::JobBuilder do
  it_should_behave_like "a job builder" do
    let(:payload) { '{"fqdn":"live.com","@version":"1","@timestamp":"2014-03-27T15:59:01.000Z","type":"do_dns_query"}' }
  end

  context "when parsing a payload that is missing an fqdn" do
    it_should_behave_like "a job builder encountering a bad payload" do
      let(:payload) { '{"address":{"ipv4":"1.2.3.4"},"source":"alexa.com","alternativeid_restriction":"public","restriction":"need-to-know","reporttime":"2014-03-27T15:59:01.000Z","alternativeid":"http://www.alexa.com/siteinfo/<fqdn>","confidence":95,"group":"everyone","assessment":"whitelist","description":"alexa #<rank>","@version":"1","@timestamp":"2014-03-27T15:59:01.000Z","type":"event"}' }
    end
  end

  context "when parsing a payload that has malformed JSON" do
    it_should_behave_like "a job builder encountering a bad payload" do
      let(:payload) { 'asdf"wqekrj' }
    end
  end
end
