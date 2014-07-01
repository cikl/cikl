require 'grape'
require 'api/v1/root'

module Cikl
  module API
    class Root < Grape::API
      prefix 'api'

      version 'v1', :using => :path
      mount ::Cikl::API::V1::Root
      add_swagger_documentation hide_documentation_path: true,
        api_version: 'v1'

      ## This is for when we get to the point of having a v2...
      #version 'v2', :using => :path
      #mount ::Cikl::API::V2::Root
      #add_swagger_documentation hide_documentation_path: true,
      #  api_version: 'v2'
    end
  end
end

