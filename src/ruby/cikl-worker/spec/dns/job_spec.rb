require 'spec_helper'
require 'cikl/worker/dns/job'
require 'shared_examples/job'

describe Cikl::Worker::DNS::Job do
  it_should_behave_like "a job" do
    let(:payload) { "google.com" }
  end

  describe "an instance" do
    let(:payload) { "google.com" }
    let(:job) { Cikl::Worker::DNS::Job.new(payload) }

    describe "#each_remaining_query" do
      it "should yield four Unbound::Query objects" do
        expect do |b|
          job.each_remaining_query(&b)
        end.to yield_successive_args(Unbound::Query, Unbound::Query, Unbound::Query, Unbound::Query)
      end

      it "should return an enumerator if no block is provided" do
        expect(job.each_remaining_query).to be_a(Enumerator)
        expect(job.each_remaining_query.to_a.count).to be(4)
      end
    end

    it "should finish the job when all queries have been finished" do
      queries = job.each_remaining_query.to_a
      expect(queries.count).to eq(4)
      expect(job.finished?).to be_false
      queries.shift.cancel!
      expect(job.finished?).to be_false
      queries.shift.cancel!
      expect(job.finished?).to be_false
      queries.shift.cancel!
      expect(job.finished?).to be_false
      queries.shift.cancel!
      expect(job.finished?).to be_true
      expect(job.each_remaining_query.to_a.count).to eq(0)
    end
  end
end

