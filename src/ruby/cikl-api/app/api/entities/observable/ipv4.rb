require 'grape'
require 'grape-entity'
module Cikl
  module API
    module Entities
      module Observable
        class Ipv4 < Grape::Entity
          expose :ipv4, format_with: lambda {|v| v.to_s unless v.nil? }
        end
      end
    end
  end
end

