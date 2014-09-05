module SpecIntegrationHelper
  @@started = false
  def self.ensure_started
    return if @@started == true

    start = Time.now
    ENV['TEST_CLUSTER_NODES'] = '1'
    require 'elasticsearch/extensions/test/cluster'
    already_running = Elasticsearch::Extensions::Test::Cluster.running?(
      on: RSpec.configuration.elasticsearch_port,
      as: RSpec.configuration.elasticsearch_cluster_name,
    )

    unless already_running == true
      Elasticsearch::Extensions::Test::Cluster.start(
        nodes: 1,
        name: RSpec.configuration.elasticsearch_cluster_name,
        port: RSpec.configuration.elasticsearch_port,
        es_params: '-D es.network.host=localhost'
      )

      at_exit do
        Elasticsearch::Extensions::Test::Cluster.stop(
          name: RSpec.configuration.elasticsearch_cluster_name,
          port: RSpec.configuration.elasticsearch_port
        )
      end
    end

    # Unnescessary?
    Fixtures::Loader.destroy!
    loader = Fixtures::Loader.new
    loader.load!

    @@started = true
  end

  def self.stop
    return unless @@started == true

    ## Unnescessary?
    #Fixtures::Loader.destroy!

    @@started = false
  end
end

RSpec.configure do |config|
  config.add_setting :elasticsearch_cluster_name, default: 'test_cikl_cluster'
  config.add_setting :elasticsearch_port, default: 9250

  config.before(:context, :integration) do
    SpecIntegrationHelper.ensure_started
  end

  config.after(:suite) do
    SpecIntegrationHelper.stop
  end
end
