require 'spec_helper'
require 'cikl/worker/base/config'
require 'shared_examples/config'

describe "Cikl::Worker::Base::Config.create_config" do
  let(:app_root) { Pathname.new("/app_root") }
  let(:config) { Cikl::Worker::Base::Config.create_config(app_root) }

  it_should_behave_like "a default config"
end

