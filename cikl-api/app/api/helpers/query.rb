require 'jbuilder'
require 'models/response'
require 'models/event'
require 'models/observables'
require 'models/observable/ipv4'
require 'models/observable/fqdn'
require 'models/observable/dns_answer'
require 'api/entities/response'

module Cikl
  module API
    module Helpers
      module Query
        def es_timestamp_query(z)
          if params.import_time_min? or params.import_time_max?
            z.child! do
              z.range do |z|
                z.set!("import_time") do |z|
                  z.gte params.import_time_min.iso8601 if params.import_time_min?
                  z.lte params.import_time_max.iso8601 if params.import_time_max?
                end
              end
            end
          end

          if params.detect_time_min? or params.detect_time_max?
            z.child! do
              z.range do |z|
                z.set!("detect_time") do |z|
                  z.gte params.detect_time_min.iso8601 if params.detect_time_min?
                  z.lte params.detect_time_max.iso8601 if params.detect_time_max?
                end
              end
            end
          end
        end

        def es_nested_any(z, path, query, fields = [])
          z.nested do 
            z.path path
            z.query do
              z.multi_match do |z|
                z.query query
                z.fields fields 
              end # multi_match
            end
          end
        end

        def run_standard_query
          query = Jbuilder.encode do |z|
            z.query do
              z.bool do

                z.must do
                  # Allow for caller to customize query.
                  z.child! do
                    z.bool do
                      yield(z)
                    end
                  end

                  es_timestamp_query(z)
                end # must
              end
            end
          end

          run_query_and_return(query)
        end

        def run_query_and_return(query)
          orig_start = get_request_start_time()
          query_start = es_query_start = Time.now
          es_response = run_query(query)
          es_query_finish = Time.now

          backend_start = Time.now
          response = build_response(es_response)
          backend_finish = Time.now
          response.timing = Cikl::Models::Timing.new(
            request_start: orig_start,
            query_start: query_start,
            elasticsearch_start: es_query_start,
            elasticsearch_finish: es_query_finish,
            backend_start: backend_start,
            backend_finish: backend_finish,
            elasticsearch_internal_query: es_response["took"].to_i
          )
          status 200
          present response, with: Cikl::API::Entities::Response, timing: params[:timing]
        end

        SORT_MAP = {
          :detect_time => :detect_time,
          :import_time => :import_time,
        }

        def run_query(query)
          query_opts = {
            size: params[:per_page],
            from: params[:start] - 1,
            fields: [],
            body: query
          }
          if sort_field = SORT_MAP[params[:order_by]]
            query_opts[:sort] = "#{sort_field}:#{params[:order]}"
          end
          search_events(query_opts)
        end

        
        def build_response(es_response)
          return Cikl::Models::Response.new(
            total_events: es_response["hits"]["total"],
            query: params,
            events: hits_to_events(es_response["hits"]["hits"]).to_a
          )
        end

        def hits_to_events_es(hits)
          return enum_for(:hits_to_events_es, hits) unless block_given?

          hits.each do |hit|
            yield Cikl::Models::Event.from_hash(hit["_source"])
          end
        end

        def hits_to_events(hits)
          return enum_for(:hits_to_events, hits) unless block_given?
          ids = hits.map { |hit| hit["_id"] }

          mongo_each_event(ids) do |obj|
            yield Cikl::Models::Event.from_hash(obj)
          end
        end

      end
    end
  end
end



