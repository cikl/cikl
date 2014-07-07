__integration_setup = false
RSpec.shared_context "integration tests", :integration do
  if __integration_setup == false

    RSpec.configure do |config|
      config.add_setting :elasticsearch_cluster_name, default: 'test_cikl_cluster'
      config.add_setting :elasticsearch_port, default: 9250

      config.before(:suite) do
        require 'elasticsearch/extensions/test/cluster'

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

        # Unnescessary?
        CiklSpec::Fixtures.destroy!
        CiklSpec::Fixtures.load!
      end

      config.after(:suite) do
        ## Unnescessary?
        #CiklSpec::Fixtures.destroy!
      end
    end
    __integration_setup = true
  end
end
