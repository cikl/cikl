require 'grape'
require 'grape-entity'
module Cikl
  module API
    module Entities
      module Observable
        class Ipv4 < Grape::Entity
          expose :ipv4
        end
      end
    end
  end
end

