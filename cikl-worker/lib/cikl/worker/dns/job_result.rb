require 'cikl/worker/base/job_result'
require 'cikl/worker/dns/payloads'
require 'multi_json'
require 'resolv'
require 'set'

module Cikl
  module Worker
    module DNS
      class JobResult
        include Cikl::Worker::Base::JobResult

        MAPPER = {
          Resolv::DNS::Resource::IN::A => Payloads::A,
          Resolv::DNS::Resource::IN::AAAA => Payloads::AAAA,
          Resolv::DNS::Resource::IN::NS => Payloads::NS,
          Resolv::DNS::Resource::IN::MX => Payloads::MX,
          Resolv::DNS::Resource::IN::CNAME => Payloads::CNAME,
        }

        def initialize(name)
          @name = name
          @start = Time.now
          @payloads = []
        end

        def parse(name, ttl, rr)
          klass = MAPPER[rr.class]

          return nil if klass.nil?

          return klass.from_rr(name, ttl, rr)
        end
        private :parse

        def handle_query_answer(query, answer)
          message = answer.to_resolv rescue nil
          return if message.nil?
          rrtype = query.rrtype 
          rrclass = query.rrclass
          n = Resolv::DNS::Name.create(query.name)

          klass = Resolv::DNS::Resource.get_class(query.rrtype, query.rrclass)

          get_additional_a_for_names = Set.new
          message.each_answer do |name, ttl, rr|
            next unless name == n 
            payload = nil
            case rr
            when klass
              payload = parse(name, ttl, rr)
            when Resolv::DNS::Resource::IN::CNAME
              #:nocov:
              payload = parse(name, ttl, rr)
              n = rr.name
              #:nocov:
            end
            next if payload.nil?
            payload.answer!
            @payloads << payload

            case payload
            when Payloads::NS, Payloads::MX
              get_additional_a_for_names << payload.fqdn
            end

          end

          return if get_additional_a_for_names.count == 0

          # Now look for additional records that match the gathered names.
          message.each_additional do |name, ttl, rr|
            if get_additional_a_for_names.include?(name)
              payload = parse(name, ttl, rr)
              next if payload.nil?
              payload.additional!
              @payloads << payload
            end
          end
        end

        def payloads
          @payloads
        end
      end

    end
  end
end
