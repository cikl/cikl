require 'spec_helper'
require 'threatinator/plugins/output/cikl'

describe Threatinator::Plugins::Output::Cikl do
  let(:bunny) { instance_double("Bunny::Session") }
  let(:exchange) { instance_double("Bunny::Exchange") }
  let(:config) { Threatinator::Plugins::Output::Cikl::Config.new }
  before :each do
    allow(::Bunny).to receive(:new).and_return(bunny)
    allow(bunny).to receive(:start)
    allow(bunny).to receive_message_chain("create_channel.default_exchange").and_return(exchange)
  end

  describe ".initialize(config)" do
    it "should initialize an instance of Bunny with the appropriate configuration" do
      url = "amqp://hey:super_secret@foobar:1234/%2Fasdf"
      config.url = url

      expect(::Bunny).to receive(:new).with(
        url, {
        recover_from_connection_close: true,
        network_recovery_interval: 5.0
      })

      described_class.new(config)
    end

    it "start up the instance of bunny" do
      expect(bunny).to receive(:start)
      described_class.new(config)
    end

    it "should request the default exchange from the instance of bunny" do
      expect(bunny).to receive_message_chain('create_channel.default_exchange')
      described_class.new(config)
    end
  end

  describe "#handle_event(ti_event)" do
    let(:serialized_event) {
      ret = {}
      ret[:oid] = "hi#{ret.object_id}"
      ret
    }
    let(:ti_event) { instance_double('Threatinator::Event') }
    let(:cikl_event) { instance_double('Cikl::Event') }
    let(:cikl_output) { described_class.new(config) }
    let(:json_string) { "bla bla bla" }

    before :each do
      config.routing_key = "foo.bar"
      allow(exchange).to receive(:publish)
      allow(cikl_output).to receive(:ti2cikl).and_return(cikl_event)
      allow(cikl_event).to receive(:to_serializable_hash).and_return(serialized_event)
      allow(MultiJson).to receive(:dump).and_return(json_string)
    end


    it "converts the ti_event to a cikl event using ti2cikl" do
      cikl_output.handle_event(ti_event)
      expect(cikl_output).to have_received(:ti2cikl).with(ti_event)
    end

    it "serializes the cikl event as JSON" do
      cikl_output.handle_event(ti_event)
      expect(MultiJson).to have_received(:dump).with(serialized_event)
    end

    it "publishes the serialized event to the provided configured routing_key" do
      cikl_output.handle_event(ti_event)
      expect(exchange).to have_received(:publish).with(json_string, routing_key: "foo.bar")
    end
  end

  describe "#finish" do
    let(:cikl_output) { described_class.new(config) }
    it "closes the bunny connection" do
      expect(bunny).to receive(:close)
      cikl_output.finish
    end
  end
end

describe Threatinator::Plugins::Output::CiklHelpers do
  describe ".ti2cikl(threatinator_event)" do
    let(:ti_event) { build(:ti_event, feed_provider: "foo", feed_name: "bar") }
    let(:the_return) { described_class.ti2cikl(ti_event) } 
    it "returns a Cikl::Event object" do
      expect(the_return).to be_a(Cikl::Event)
    end

    it "populates the feed_provider and feed_name" do
      expect(the_return.feed_provider).to eq("foo")
      expect(the_return.feed_name).to eq("bar")
    end

    context "when threatinator_event has no ipv4 addresses" do
      let(:ti_event) { build(:ti_event, ipv4s: []) }
      describe "the generated Cikl::Event" do
        specify "has no ipv4 observables" do
          expect(the_return.observables.ipv4).to be_empty
        end
      end
    end

    context "when threatinator_event has ipv4 addresses" do
      let(:ti_event) { build(:ti_event, ipv4s: ["1.2.3.4", "5.6.7.8"]) }

      describe "the generated Cikl::Event" do
        specify "has matching ipv4 observables" do
          expect(the_return.observables.ipv4).to match([
            build(:cikl_ipv4, ipv4: '1.2.3.4'),
            build(:cikl_ipv4, ipv4: '5.6.7.8'),
          ])
        end
      end
    end

    context "when threatinator_event has no fqdn addresses" do
      let(:ti_event) { build(:ti_event, fqdns: []) }
      describe "the generated Cikl::Event" do
        specify "has no fqdn observables" do
          expect(the_return.observables.fqdn).to be_empty
        end
      end
    end

    context "when threatinator_event has fqdn addresses" do
      let(:ti_event) { build(:ti_event, fqdns: ["google.com", "yahoo.com"]) }

      describe "the generated Cikl::Event" do
        specify "has matching fqdn observables" do
          expect(the_return.observables.fqdn).to match([
            build(:cikl_fqdn, fqdn: 'google.com'),
            build(:cikl_fqdn, fqdn: 'yahoo.com'),
          ])
        end
      end
    end
  end
end
