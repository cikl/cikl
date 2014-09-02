require 'grape'
require 'grape-entity'
module Cikl
  module API
    module Entities
      module Observable
        class Fqdn < Grape::Entity
          expose :fqdn
        end
      end
    end
  end
end


