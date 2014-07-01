require 'grape'
require 'grape-entity'
require 'api/entities/observable/dns_answer'
require 'api/entities/observable/ipv4'
require 'api/entities/observable/fqdn'

module Cikl
  module API
    module Entities
      class QueryParams < Grape::Entity
        format_with(:iso_timestamp) { |dt| dt.iso8601 if dt.respond_to?(:iso8601) }
        expose :start,
          documentation: {
            type: Integer,
            default: 1,
            desc: "The index of the current set of events into the total set of events, where the index of the first event is 1"
          }

        expose :per_page, 
          documentation: {
            type: Integer,
            default: 50, 
            in_range: 1..2000,
            desc: "Number of events per page. Expects: Integer between 1 and 2000. Default: 50."
          }

        VALID_ORDER_BY_VALUES = [
          :import_time,
          :detect_time
        ]

        expose :order_by,
          documentation: {
            type: Symbol,
            default: :import_time,
            values: VALID_ORDER_BY_VALUES,
            desc: "Event field with which to order the events. Default: import_time. Accepts: #{VALID_ORDER_BY_VALUES.join(', ')}"
          }

        VALID_ORDER_VALUES = [ :asc, :desc ]
        expose :order,
          documentation: {
            type: Symbol,
            default: :desc,
            values: VALID_ORDER_VALUES,
            desc: "Order in which to arrange events, ascending or descending. Default: desc. Accepts: #{VALID_ORDER_VALUES.join(', ')}"
          }

        expose :timing, {
          documentation: {
            type: Integer, 
            default: 0, 
            desc: "Include timing information in response. 1 for true, 0 for false."
          }
        }

        with_options(format_with: :iso_timestamp) do
          expose :import_time_min,
            documentation: {
              type: DateTime,
              default: lambda { DateTime.now - 30 } # 30 days ago 
            }

          expose :import_time_max,
            documentation: {
              type: DateTime
            }

          expose :detect_time_min,
            documentation: {
              type: DateTime
            }

          expose :detect_time_max,
            documentation: {
              type: DateTime
            }
        end
      end

    end
  end
end


