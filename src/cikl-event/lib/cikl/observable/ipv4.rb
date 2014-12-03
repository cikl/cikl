require 'cikl/base_model'
require 'equalizer'

module Cikl
  module Observable

    class Ipv4 < Cikl::BaseModel
      attribute :ipv4
      include Equalizer.new(*attribute_set.map(&:name))
    end

  end
end
