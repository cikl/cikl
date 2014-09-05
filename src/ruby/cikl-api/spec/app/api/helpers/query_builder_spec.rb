require 'spec_helper'
require 'api/helpers/query_builder'
require 'models/query_params'

describe Cikl::API::Helpers::QueryBuilder do
  let(:builder) { Cikl::API::Helpers::QueryBuilder }

  describe :build_nested do
    it "should raise TypeError when path is not a String" do
      expect {builder.build_nested(1234, "foo", ["bar"])}.to raise_error(TypeError)
      expect {builder.build_nested(nil, "foo", ["bar"])}.to raise_error(TypeError)
      expect {builder.build_nested(Object.new, "foo", ["bar"])}.to raise_error(TypeError)
      expect {builder.build_nested([], "foo", ["bar"])}.to raise_error(TypeError)
    end
    it "should raise TypeError when fields is not an Array" do 
      expect {builder.build_nested("asdf", "foo", 1234)}.to raise_error(TypeError)
      expect {builder.build_nested("asdf", "foo", nil)}.to raise_error(TypeError)
      expect {builder.build_nested("1234", "foo", { foo: 1234 })}.to raise_error(TypeError)
    end
    it "should expect fields to have at least one value" do
      expect {builder.build_nested("1234", "foo", [])}.to raise_error(ArgumentError)
    end

    describe "the return" do
      subject { builder.build_nested('a_path', 'a_value', ['field1', 'field2']) }

      it { is_expected.to be_a(::Hash) }
      it "should be a properly formatted hash" do
        expect(subject).to eq(
          {
            nested: {
              path: 'a_path',
              query: {
                multi_match: {
                  query: 'a_value',
                  fields: ['field1', 'field2'] 
                }
              }
            }
          }
        )
      end
    end
  end

  describe :build_fqdn_queries do
    context "for a given fqdn" do
      let(:fqdn) { "myfqdn.com" }
      let(:ret) { builder.build_fqdn_queries(fqdn) }

      it "should return two queries" do
        expect(ret.length).to eq(2)
      end
      describe "query 1" do
        subject { ret[0] }
        it "should be for fqdn's fqdn" do
          expect(subject).to eq(builder.build_nested("observables.fqdn", fqdn, ["observables.fqdn.fqdn"]))
        end
      end
      describe "query 2" do
        subject { ret[1] }
        it "should query dns_answer's name and fqdn" do
            expect(subject).to eq(builder.build_nested("observables.dns_answer", fqdn, ["observables.dns_answer.name", "observables.dns_answer.fqdn"]))
        end
      end
    end
  end

  describe :build_ipv4_queries do
    context "for a given ipv4" do
      let(:ipv4) { "1.2.3.4" }
      let(:ret) { builder.build_ipv4_queries(ipv4) }

      it "should return two queries" do
        expect(ret.length).to eq(2)
      end
      describe "query 1" do
        subject { ret[0] }
        it "should be for ipv4's ipv4" do
          expect(subject).to eq(builder.build_nested("observables.ipv4", ipv4, ["observables.ipv4.ipv4"]))
        end
      end
      describe "query 2" do
        subject { ret[1] }
        it "should query dns_answer's ipv4" do
            expect(subject).to eq(builder.build_nested("observables.dns_answer", ipv4, ["observables.dns_answer.ipv4"]))
        end
      end
    end
  end

  describe :build_range_timestamp do
    it "should return nil if there is no min or max" do
      expect(builder.build_range_timestamp("foo", nil, nil)).to be_nil
    end
    it "should return a range query with the lower bound of min" do
      now = Time.now
      expect(builder.build_range_timestamp(:foo, now, nil)).to eq({
        range: {
          foo: {
            gte: now.iso8601
          }
        }
      })
    end
    it "should return a range query with the upper bound of max" do
      now = Time.now
      expect(builder.build_range_timestamp(:foo, nil, now)).to eq({
        range: {
          foo: {
            lte: now.iso8601
          }
        }
      })
    end
  end
end
