require 'jbuilder'
require 'models/response'
require 'cikl/event'
require 'api/entities/response'

module Cikl
  module API
    module Helpers
      module Query
        IPV4_QUERY = [
          ["observables.ipv4", ["observables.ipv4.ipv4"]],
          ["observables.dns_answer", ["observables.dns_answer.ipv4"]],
        ]
        FQDN_QUERY = [
          ["observables.fqdn", ["observables.fqdn.fqdn"]],
          ["observables.dns_answer", ["observables.dns_answer.name", "observables.dns_answer.fqdn"]],
        ]

        def es_time_range(field, min, max)
          range = {}
          range[:gte] = min.iso8601 unless min.nil? 
          range[:lte] = max.iso8601 unless max.nil? 
          return nil if range.empty?
          return { range: { field => range } }
        end

        def es_nested_any(path, query, fields = [])
          { 
            nested: {
              path: path,
              query: {
                multi_match: {
                  query: query,
                  fields: fields
                }
              }
            }
          }
        end

        def es_aggs
          aggs = {}
          aggs[:max_detect_time] =  {
            max: {
              field: :'event.detect_time'
            }
          }
          aggs[:min_detect_time] =  {
            min: {
              field: :'event.detect_time'
            }
          }
          aggs[:max_import_time] = {
            max: {
              field: :'event.import_time'
            }
          }
          aggs[:min_import_time] = {
            min: {
              field: :'event.import_time'
            }
          }
          aggs[:sources_top20] = {
            terms: {
              field: :'event.source',
              size: 20
            }
          }
          aggs[:feed_providers_top20] = {
            terms: {
              field: :'event.feed_provider',
              size: 20
            }
          }

          # TODO: Improve this by storing provider/name in elasticsearch.
          aggs[:feed_names_top20] = {
            terms: {
              field: :'event.feed_name',
              size: 20
            }
          }
          aggs
        end

        def run_standard_query(query_params)
          musts = []
          shoulds = []

          if q = es_time_range(:import_time, query_params.import_time_min, query_params.import_time_max)
            musts << q
          end

          if q = es_time_range(:detect_time, query_params.detect_time_min, query_params.detect_time_max)
            musts << q
          end

          if query_params.ipv4?
            IPV4_QUERY.each do |path, fields|
              shoulds << es_nested_any(path, query_params.ipv4, fields)
            end
          end

          if query_params.fqdn?
            FQDN_QUERY.each do |path, fields|
              shoulds << es_nested_any(path, query_params.fqdn, fields)
            end
          end

          if musts.empty? && shoulds.empty?
            musts << { match_all: {} }
          end

          query = Jbuilder.encode do |json|
            json.query do
              json.bool do
                json.must musts unless musts.empty?

                unless shoulds.empty?
                  json.minimum_should_match 1
                  json.should shoulds
                end

              end
            end
            json.aggs es_aggs
          end

          run_query_and_return(query, query_params)
        end

        def run_query_and_return(query, query_params)
          orig_start = get_request_start_time()
          query_start = es_query_start = Time.now
          es_response = run_query(query, query_params)
          es_query_finish = Time.now

          backend_start = Time.now
          response = build_response(es_response, query_params)
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
          present response, with: Cikl::API::Entities::Response, timing: query_params[:timing]
        end

        SORT_MAP = {
          :detect_time => :detect_time,
          :import_time => :import_time,
        }

        def run_query(query, query_params)
          query_opts = {
            size: query_params[:per_page],
            from: query_params[:start] - 1,
            fields: [],
            body: query
          }
          if sort_field = SORT_MAP[query_params[:order_by]]
            query_opts[:sort] = "#{sort_field}:#{query_params[:order]}"
          end
          search_events(query_opts)
        end

        def build_facets(es_response) 
          aggs = es_response["aggregations"]
          sources = aggs["sources_top20"]["buckets"].map { |h| [h['key'], h['doc_count']] }
          feed_providers = aggs["feed_providers_top20"]["buckets"].map { |h| [h['key'], h['doc_count']] }
          feed_names = aggs["feed_names_top20"]["buckets"].map { |h| [h['key'], h['doc_count']] }

          opts = {
            sources: sources,
            feed_providers: feed_providers,
            feed_names: feed_names
          }
          if min_detect_time = aggs["min_detect_time"]["value"]
            opts[:min_detect_time] = Time.at(min_detect_time / 1000.0).to_datetime
          end
          if max_detect_time = aggs["max_detect_time"]["value"]
            opts[:max_detect_time] = Time.at(max_detect_time/1000.0).to_datetime
          end
          if min_import_time = aggs["min_import_time"]["value"]
            opts[:min_import_time] = Time.at(min_import_time/1000.0).to_datetime
          end
          if max_import_time = aggs["max_import_time"]["value"]
            opts[:max_import_time] = Time.at(max_import_time/1000.0).to_datetime
          end

          Cikl::Models::Facets.new(opts)
        end
        
        def build_response(es_response, query_params)
          return Cikl::Models::Response.new(
            total_events: es_response["hits"]["total"],
            query: query_params,
            events: hits_to_events(es_response["hits"]["hits"]).to_a,
            facets: build_facets(es_response)
          )
        end

        def hits_to_events_es(hits)
          return enum_for(:hits_to_events_es, hits) unless block_given?

          hits.each do |hit|
            yield Cikl::Event.from_hash(hit["_source"])
          end
        end

        def hits_to_events(hits)
          return enum_for(:hits_to_events, hits) unless block_given?
          ids = hits.map { |hit| hit["_id"] }

          mongo_each_event(ids) do |obj|
            yield Cikl::Event.from_hash(obj)
          end
        end

      end
    end
  end
end



