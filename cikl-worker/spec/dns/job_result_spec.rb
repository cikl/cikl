require 'spec_helper'
require 'cikl/worker/dns/job_result'
require 'cikl/worker/dns/payloads'
require 'unbound'
require 'multi_json'
require 'resolv'

describe Cikl::Worker::DNS::JobResult do
  DNS_GOOGLE_NS = WorkerHelper.hex2bin 'd7cf8180000100040000000406676f6f676c6503636f6d0000020001c00c00020001000545e80006036e7333c00cc00c00020001000545e80006036e7334c00cc00c00020001000545e80006036e7331c00cc00c00020001000545e80006036e7332c00cc02800010001000545e80004d8ef240ac03a00010001000545e80004d8ef260ac04c00010001000545e80004d8ef200ac05e00010001000545e80004d8ef220a'
  DNS_GOOGLE_A = WorkerHelper.hex2bin 'facd81800001000b0000000006676f6f676c6503636f6d0000010001c00c000100010000009d0004adc22e23c00c000100010000009d0004adc22e29c00c000100010000009d0004adc22e27c00c000100010000009d0004adc22e25c00c000100010000009d0004adc22e2ec00c000100010000009d0004adc22e21c00c000100010000009d0004adc22e26c00c000100010000009d0004adc22e28c00c000100010000009d0004adc22e24c00c000100010000009d0004adc22e20c00c000100010000009d0004adc22e22'
  DNS_GOOGLE_AAAA = WorkerHelper.hex2bin '4fd98180000100010000000006676f6f676c6503636f6d00001c0001c00c001c00010000012c00102607f8b0400908030000000000001004'
  DNS_GOOGLE_MX = WorkerHelper.hex2bin '425e8180000100050000000506676f6f676c6503636f6d00000f0001c00c000f000100000258000c000a056173706d78016cc00cc00c000f0001000002580009003204616c7434c02ac00c000f0001000002580009002804616c7433c02ac00c000f0001000002580009001404616c7431c02ac00c000f0001000002580009001e04616c7432c02ac02a000100010000012500044a7d8e1ac04200010001000001250004adc2411ac05700010001000001250004adc2431ac06c00010001000001250004adc2441ac081000100010000012500044a7d831a'

  DNS_YAHOO_A = WorkerHelper.hex2bin 'edd98180000100060000000003777777057961686f6f03636f6d0000010001c00c0005000100000113000f0666642d667033037767310162c010c02b000500010000011300090664732d667033c032c046000500010000002300150e64732d616e792d6670332d6c666203776131c036c05b000500010000011300120f64732d616e792d6670332d7265616cc06ac07c00010001000000240004628bb718c07c00010001000000240004628bb495'

  def create_answer(str)
    ret = double("answer")
    ret.stub(:to_resolv).and_return(Resolv::DNS::Message.decode(str))
    ret
  end

  def create_query(name, rrtype, rrclass = 1)
    unless name.end_with?(".")
      name << '.'
    end
    name.downcase!
    Unbound::Query.new(name, rrtype, rrclass)
  end

  def _n(name)
    unless name.end_with?('.')
      name << '.'
    end
    Resolv::DNS::Name.create(name)
  end

  def _ipv4(ip)
    Resolv::IPv4.create(ip)
  end

  def _ipv6(ip)
    Resolv::IPv6.create(ip)
  end

  def _a(name, ttl, ip)
    Cikl::Worker::DNS::Payloads::A.new(_n(name), ttl, _ipv4(ip))
  end
  def _aaaa(name, ttl, ip)
    Cikl::Worker::DNS::Payloads::AAAA.new(_n(name), ttl, _ipv6(ip))
  end

  def _ns(name, ttl, fqdn)
    Cikl::Worker::DNS::Payloads::NS.new(_n(name), ttl, _n(fqdn))
  end

  def _cname(name, ttl, fqdn)
    Cikl::Worker::DNS::Payloads::CNAME.new(_n(name), ttl, _n(fqdn))
  end
  def _mx(name, ttl, fqdn)
    Cikl::Worker::DNS::Payloads::MX.new(_n(name), ttl, _n(fqdn))
  end

  let(:query_ns) {create_query('google.com', Resolv::DNS::Resource::IN::NS::TypeValue)}
  let(:query_a) {create_query('google.com', Resolv::DNS::Resource::IN::A::TypeValue)}
  let(:query_yahoo_a) {create_query('www.yahoo.com', Resolv::DNS::Resource::IN::A::TypeValue)}
  let(:query_aaaa) {create_query('google.com', Resolv::DNS::Resource::IN::AAAA::TypeValue)}
  let(:query_mx) {create_query('google.com', Resolv::DNS::Resource::IN::MX::TypeValue)}

  let(:answer_ns) {create_answer(DNS_GOOGLE_NS)}
  let(:answer_a) {create_answer(DNS_GOOGLE_A)}
  let(:answer_yahoo_a) {create_answer(DNS_YAHOO_A)}
  let(:answer_aaaa) {create_answer(DNS_GOOGLE_AAAA)}
  let(:answer_mx) {create_answer(DNS_GOOGLE_MX)}


  context "handling a response for google.com" do
    let(:job_result) { Cikl::Worker::DNS::JobResult.new("google.com") }

    context "an NS query" do
      before :each do
        job_result.handle_query_answer(query_ns, answer_ns)
      end
      describe "#payloads" do
        before :each do
          @payloads = job_result.payloads
        end

        specify "there should be 8 payloads, total" do
          expect(@payloads.length).to eq(8)
        end

        specify "should match the proper NS records" do
          expect(@payloads).to match_array(
            [
              _ns('google.com', 1234, 'ns1.google.com'),
              _ns('google.com', 1234, 'ns2.google.com'),
              _ns('google.com', 1234, 'ns3.google.com'),
              _ns('google.com', 1234, 'ns4.google.com'),
              _a('ns1.google.com', 1234, '216.239.32.10').additional!,
              _a('ns2.google.com', 1234, '216.239.34.10').additional!,
              _a('ns3.google.com', 1234, '216.239.36.10').additional!,
              _a('ns4.google.com', 1234, '216.239.38.10').additional!,
            ]
          )
        end
      end

    end

    context "an A query" do
      before :each do
        job_result.handle_query_answer(query_a, answer_a)
      end
      describe "#payloads" do
        before :each do
          @payloads = job_result.payloads
        end

        specify "there should be 11 payloads, total" do
          expect(@payloads.length).to eq(11)
        end

        specify "the payloads should match the proper A records" do
          expect(@payloads).to match_array(
            [
              _a('google.com', 1234, '173.194.46.32'),
              _a('google.com', 1234, '173.194.46.33'),
              _a('google.com', 1234, '173.194.46.34'),
              _a('google.com', 1234, '173.194.46.35'),
              _a('google.com', 1234, '173.194.46.36'),
              _a('google.com', 1234, '173.194.46.37'),
              _a('google.com', 1234, '173.194.46.38'),
              _a('google.com', 1234, '173.194.46.39'),
              _a('google.com', 1234, '173.194.46.40'),
              _a('google.com', 1234, '173.194.46.41'),
              _a('google.com', 1234, '173.194.46.46'),
            ]
          )
        end
      end
    end

    context "an AAAA query" do
      before :each do
        job_result.handle_query_answer(query_aaaa, answer_aaaa)
      end
      describe "#payloads" do
        before :each do
          @payloads = job_result.payloads
        end

        specify "there should be 1 payloads, total" do
          expect(@payloads.length).to eq(1)
        end

        specify "the payloads should match the proper AAAA records" do
          expect(@payloads).to match_array(
            [
              _aaaa("google.com", 1234, "2607:f8b0:4009:803::1004")
            ]
          )
        end
      end

    end

    context "an MX query" do
      before :each do
        job_result.handle_query_answer(query_mx, answer_mx)
      end
      describe "#payloads" do
        before :each do
          @payloads = job_result.payloads
        end

        specify "there should be 10 payloads, total" do
          expect(@payloads.length).to eq(10)
        end

        specify "the payloads should match the proper MX records" do
          expect(@payloads).to match_array(
            [
              _mx("google.com", 1234, "aspmx.l.google.com"),
              _mx("google.com", 1234, "alt4.aspmx.l.google.com"),
              _mx("google.com", 1234, "alt3.aspmx.l.google.com"),
              _mx("google.com", 1234, "alt1.aspmx.l.google.com"),
              _mx("google.com", 1234, "alt2.aspmx.l.google.com"),

              _a("aspmx.l.google.com", 1234, "74.125.142.26").additional!,
              _a("alt4.aspmx.l.google.com", 1234, "173.194.65.26").additional!,
              _a("alt3.aspmx.l.google.com", 1234, "173.194.67.26").additional!,
              _a("alt1.aspmx.l.google.com", 1234, "173.194.68.26").additional!,
              _a("alt2.aspmx.l.google.com", 1234, "74.125.131.26").additional!,
            ]
          )
        end
      end
    end

    context "an A query with CNAMEs in the answer" do
      before :each do
        job_result.handle_query_answer(query_yahoo_a, answer_yahoo_a)
      end
      describe "#payloads" do
        before :each do
          @payloads = job_result.payloads
        end

        specify "there should be 6 payloads, total" do
          expect(@payloads.length).to eq(6)
        end

        specify "the payloads should match the proper MX records" do
          expect(@payloads).to match_array(
            [
              _cname("www.yahoo.com", 1234, "fd-fp3.wg1.b.yahoo.com"),
              _cname("fd-fp3.wg1.b.yahoo.com", 1234, "ds-fp3.wg1.b.yahoo.com"),
              _cname("ds-fp3.wg1.b.yahoo.com", 1234, "ds-any-fp3-lfb.wa1.b.yahoo.com"),
              _cname("ds-any-fp3-lfb.wa1.b.yahoo.com", 1234, "ds-any-fp3-real.wa1.b.yahoo.com"),
              _a("ds-any-fp3-real.wa1.b.yahoo.com", 1234, "98.139.183.24"),
              _a("ds-any-fp3-real.wa1.b.yahoo.com", 1234, "98.139.180.149"),
            ]
          )
        end
      end
    end

  end

end
