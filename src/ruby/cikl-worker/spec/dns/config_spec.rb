require 'spec_helper'
require 'cikl/worker/dns/config'
require 'shared_examples/config'

describe "Cikl::Worker::Base::Config.create_config('/app_root')" do
  let(:app_root) { Pathname.new("/app_root") }
  let(:config) { Cikl::Worker::DNS::Config.create_config(app_root) }

  it_should_behave_like "a default config"
  context :dns do
    subject { config[:dns] }
    its([:unbound_config_file]) { should eq(app_root.join("config/unbound.conf").to_s) }
    its([:root_hints_file]) { should eq(app_root.join("config/named.root").to_s) }
  end
end


