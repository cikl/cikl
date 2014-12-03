require 'cikl/worker/dns/job_result'
require 'cikl/worker/base/job'
require 'resolv'
require 'unbound'

module Cikl
  module Worker
    module DNS
      class Job < Cikl::Worker::Base::Job
        RR_NS = Resolv::DNS::Resource::IN::NS::TypeValue
        RR_A = Resolv::DNS::Resource::IN::A::TypeValue
        RR_AAAA = Resolv::DNS::Resource::IN::AAAA::TypeValue
        RR_MX = Resolv::DNS::Resource::IN::MX::TypeValue
        RR_C_IN = 1

        def initialize(name, opts = {})
          super(opts)
          unless name.end_with?(".")
            name << '.'
          end
          name.downcase!
          @name = name
          @remaining_queries = {}
          @queries = []
          @result = JobResult.new(name)
          @answer_cb = @result.method(:handle_query_answer)
          @finish_cb = self.method(:finish_cb)

          add_query(RR_NS, RR_C_IN)
          add_query(RR_A, RR_C_IN)
          add_query(RR_AAAA, RR_C_IN)
          add_query(RR_MX, RR_C_IN)
        end

        def each_remaining_query
          unless block_given?
            return @remaining_queries.each_value.to_enum
          end
          @remaining_queries.each_value do |query|
            yield query
          end
        end

        private

        def add_query(rrtype, rrclass)
          query = Unbound::Query.new(@name, rrtype, rrclass)
          query.on_answer(@answer_cb)
          query.on_finish(@finish_cb)
          @queries.push(query)
          @remaining_queries[query.object_id] = query
          query
        end

        def finish_cb(query)
          @remaining_queries.delete(query.object_id)
          if @remaining_queries.empty?
            finish!(@result)
          end
        end
      end
    end
  end
end


