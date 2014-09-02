require 'grape'

module Cikl
  module API
    module Validators
      class InRange < Grape::Validations::SingleOptionValidator
        def validate_param!(attr_name, params)
          unless @option.include?(params[attr_name])
            raise Grape::Exceptions::Validation, param: @scope.full_name(attr_name), message: "is not in range #{@option.to_s}"
          end
        end
      end
    end
  end
end
