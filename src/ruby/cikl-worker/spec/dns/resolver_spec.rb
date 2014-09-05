require 'spec_helper'
require 'cikl/worker/dns/resolver'
require 'cikl/worker/dns/config'
require 'unbound'

describe Cikl::Worker::DNS::Resolver do
  include WorkerHelper
  let(:config) {
    ret = Cikl::Worker::DNS::Config.create_config(WorkerHelper::PROJECT_ROOT)
    ret[:dns][:unbound_config_file] = unbound_config_file("local_zone.conf")
    ret
  }
  before :each do
    @resolver = Cikl::Worker::DNS::Resolver.new(config)
  end

  after :each do
    @resolver.stop if @resolver.running?
  end

  describe "#running?" do
    it "should be false if not started" do
      expect(@resolver.running?).to be_false
    end
    it "should be true if started" do
      @resolver.start
      expect(@resolver.running?).to be_true
    end
  end

  describe "#send_query" do
    it "should call Unbound::Resolver#send_query" do
      query = Unbound::Query.new('fakedomain.local.', 1, 1)
      expect_any_instance_of(Unbound::Resolver).to receive(:send_query).with(query)
      @resolver.send_query(query)
    end
  end

  describe "#cancel_query" do
    it "should call Unbound::Resolver#cancel_query" do
      query = Unbound::Query.new('fakedomain.local.', 1, 1)
      expect_any_instance_of(Unbound::Resolver).to receive(:cancel_query).with(query).and_call_original
      @resolver.start
      @resolver.send_query(query)
      @resolver.cancel_query(query)
      sleep 1
    end
  end

  context "a running resolver" do
    before :each do
      @resolver.start
    end

    it "should be able to get an answer for a query" do
      query = Unbound::Query.new('fakedomain.local.', 1, 1)

      result = nil
      latch = Thread.new { sleep }

      query.on_finish do 
        latch.wakeup
      end
      query.on_answer do |q, r|
        result = r
      end

      @resolver.send_query(query)

      latch.join(2)

      expect(result).to be_a(Unbound::Result)
    end
  end

end


