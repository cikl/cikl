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

describe 'Cikl API v1 query/ipv4 endpoint', :integration, :app do
  let(:query_proc) { 
    lambda do |ipv4, opts = {} |
      query_opts = opts.merge({ ipv4: ipv4})
      post '/api/v1/query/ipv4', query_opts
    end
  }

  it_should_behave_like 'an IPv4 query endpoint'
end
