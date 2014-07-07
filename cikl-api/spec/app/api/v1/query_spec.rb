require 'spec_helper'

describe 'Cikl API v1 query/fqdn endpoint', :integration, :app do
  let(:query_proc) { 
    lambda do |fqdn, opts = {} |
      query_opts = opts.merge({ fqdn: fqdn })
      post '/api/v1/query/fqdn', query_opts
    end
  }

  it_should_behave_like 'an FQDN query endpoint'
end
