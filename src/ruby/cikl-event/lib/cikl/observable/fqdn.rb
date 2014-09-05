require 'cikl/base_model'
require 'equalizer'

module Cikl
  module Observable

    class Fqdn < Cikl::BaseModel
      attribute :fqdn, String
      include Equalizer.new(*attribute_set.map(&:name))
    end

  end
end
