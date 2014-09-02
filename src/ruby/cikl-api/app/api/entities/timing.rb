require 'grape'
require 'grape-entity'
module Cikl
  module API
    module Entities
      class Timing < Grape::Entity
        expose :pre_query_milliseconds, as: :pre_query
        expose :query do
          expose :elasticsearch_total_milliseconds, as: :elasticsearch
          expose :backend_total_milliseconds, as: :backend
        end
        expose :query_total_milliseconds, as: :query_total
        expose :rendering do |i,o|
          ((Time.now - i.backend_finish) * 1000).to_i 
        end
        expose :response_total do |i, o|
          ((Time.now - i.request_start) * 1000).to_i 
        end
      end
    end
  end
end


