
module Cikl
  module API
    module Helpers
      module QueryBuilder
        IPV4_QUERY = [
          ["observables.ipv4", ["observables.ipv4.ipv4"]],
          ["observables.dns_answer", ["observables.dns_answer.ipv4"]],
        ]

        FQDN_QUERY = [
          ["observables.fqdn", ["observables.fqdn.fqdn"]],
          ["observables.dns_answer", ["observables.dns_answer.name", "observables.dns_answer.fqdn"]],
        ]

        def self.build_range_timestamp(field, min, max)
          range_data = {}
          range_data[:gte] = min.iso8601 unless min.nil?
          range_data[:lte] = max.iso8601 unless max.nil?
          return nil if range_data.empty?

          return {
            range: {
              field => range_data
            }
          }
        end

        def self.build_nested(path, value, fields)
          unless path.kind_of?(::String)
            raise TypeError.new("path must be a string")
          end
          unless fields.kind_of?(::Array)
            raise TypeError.new("fields must be an Array")
          end
          unless fields.length >= 1
            raise ArgumentError.new("fields must have at least one field")
          end

          {
            nested: {
              path: path,
              query: {
                multi_match: {
                  query: value,
                  fields: fields
                }
              }
            }
          }
        end

        def self.build_fqdn_queries(fqdn)
          ret = []
          FQDN_QUERY.each do |path, fields|
            ret << build_nested(path, fqdn, fields)
          end
          ret
        end

        def self.build_ipv4_queries(ipv4)
          ret = []
          IPV4_QUERY.each do |path, fields|
            ret << build_nested(path, ipv4, fields)
          end
          ret
        end

        # @param [Cikl::Models::QueryParams]
        def self.build_standard_query(query_params)
          musts = [es_timestamp_query]

          {
            query: {
              bool: {
                must: [
                  es_timestamp_query,
                  user_query
                ]
              }
            }
          }
        end
      end
    end
  end
end
