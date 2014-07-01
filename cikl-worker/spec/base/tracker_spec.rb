require 'spec_helper'
require 'cikl/worker/base/tracker'

describe Cikl::Worker::Base::Tracker do
  before :each do
    @timeout = 10.0
    @tracker = Cikl::Worker::Base::Tracker.new(@timeout)
  end
  describe "#has?" do
    it "should return true if it has the object" do
      x = Object.new
      @tracker.add(x)
      expect(@tracker.has?(x)).to be_true
    end
    it "should return false if it does not have the object" do
      expect(@tracker.has?(Object.new)).to be_false
    end

    it "should return false if the object has been deleted" do
      x = Object.new
      @tracker.add(x)
      @tracker.delete(x)
      expect(@tracker.has?(x)).to be_false
    end
  end

  describe "#next_prune" do
    it "should return nil if the tracker is empty" do
      expect(@tracker.next_prune).to be_nil
    end
    it "should return a Time object" do
      @tracker.add(Object.new)
      expect(@tracker.next_prune).to be_a(Time)
    end
    it "should return time for when the next prune should occur" do
      expected_deadline = Time.now + @timeout
      @tracker.add(Object.new)
      expect(@tracker.next_prune).to be_within(1.0).of(expected_deadline)
    end
  end

  describe "#first" do
    it "should return nil if the tracker is empty" do
      expect(@tracker.first).to be_nil
    end
    it "should return the first object in the tracker by age" do
      obj1 = Object.new
      obj2 = Object.new
      obj3 = Object.new
      @tracker.add(obj1)
      @tracker.add(obj2)
      @tracker.add(obj3)
      expect(@tracker.first).to be(obj1)
    end
    it "should return the first available object if those before it have been deleted" do
      obj1 = Object.new
      obj2 = Object.new
      obj3 = Object.new
      @tracker.add(obj1)
      @tracker.add(obj2)
      @tracker.add(obj3)
      @tracker.delete(obj1)
      @tracker.delete(obj2)
      expect(@tracker.first).to be(obj3)
    end
  end

  describe "#count" do
    it "should be 0 at first" do
      expect(@tracker.count).to eq(0)
    end
    it "should return the number of objects currently being tracked" do
      expect(@tracker.count).to eq(0)
      @tracker.add(Object.new)
      expect(@tracker.count).to eq(1)
      99.times do 
        @tracker.add(Object.new)
      end
      expect(@tracker.count).to eq(100)
    end
  end

  describe "#add" do
    it "should begin tracking the object" do
      expect(@tracker.count).to eq(0)
      @tracker.add(Object.new)
      expect(@tracker.count).to eq(1)
      99.times do 
        @tracker.add(Object.new)
      end
      expect(@tracker.count).to eq(100)
    end

    it "should raise an ArgumentError if the object is already being tracked" do
      object = Object.new
      @tracker.add(object)
      expect {
        @tracker.add(object)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#delete" do
    it "should stop tracking the object" do
      object = Object.new
      @tracker.add(object)
      expect(@tracker.has?(object)).to be_true
      @tracker.delete(object)
      expect(@tracker.has?(object)).to be_false
    end

    it "should return the object if it been deleted" do
      object = Object.new
      @tracker.add(object)
      expect(@tracker.delete(object)).to be(object)
    end

    it "should return nil if it was not tracking the object" do
      object = Object.new
      expect(@tracker.delete(object)).to be_nil
    end
  end

  describe "#prune_old" do
    it "should return an empty array if there's nothing to prune" do
      expect(@tracker.prune_old).to eq([])
    end

    it "should prune objects older than the provided epoch timestamp (float)" do
      mid_time = nil
      1.upto(20) do |i|
        @tracker.add(i)

        if (i == 10)
          sleep 0.1 # JRuby doesn't handle times < 0.001
          mid_time = Time.now
          sleep 0.1
        end
      end

      expect(@tracker.count).to eq(20)
      ret = @tracker.prune_old(mid_time + @timeout)
      expect(ret.count).to eq(10)
      expect(@tracker.count).to eq(10)
    end

    it "should return each pruned object" do 
      mid_time = nil
      expected_objects = []
      1.upto(20) do |i|
        object = Object.new
        @tracker.add(object)
        if i <= 10
          expected_objects << object
        end

        if (i == 10)
          sleep 0.1
          mid_time = Time.now
          sleep 0.1
        end
      end

      expect(@tracker.count).to eq(20)
      actual_objects = @tracker.prune_old(mid_time + @timeout)
      expect(@tracker.count).to eq(10)
      expect(actual_objects).to match_array(expected_objects)
    end

    it "shouldn't prune anything if the timeout is very far in the future" do
      timeout = 10000
      tracker = Cikl::Worker::Base::Tracker.new(timeout)
      20.times do 
        tracker.add(Object.new)
      end
      expect(tracker.count).to eq(20)
      tracker.prune_old()
      expect(tracker.count).to eq(20)
    end
  end
end



