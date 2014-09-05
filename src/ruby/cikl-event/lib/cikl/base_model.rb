require 'virtus'
require 'pp'

module Cikl
  class BaseModel
    include Virtus.model

    # Serializes this object into a hash. Any decendant of BaseModel will be
    # serialized using #to_serializable_hash
    # @return [Hash]
    def to_serializable_hash
      ret = {}
      attributes.each do |k, v|
        ret[k] = v unless v.nil?
      end
      ret
    end

  end
end
