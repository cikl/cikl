
shared_examples_for "a default config" do
  subject { config }
  its(:results_routing_key) { should be_nil }
  its(:jobs_routing_key) { should be_nil }
  its(:job_timeout) { should eq(10.0)}
  its(:job_channel_prefetch) { should eq(128)}
  its(:worker_name) { should eq( ENV["HOSTNAME"] || Socket.gethostname || "unknown") }

  context :amqp do
    subject { config[:amqp] }
    its([:host]) { should eq("localhost") }
    its([:port]) { should eq(5672) }
    its([:username]) { should eq("guest") }
    its([:password]) { should eq("guest") }
    its([:vhost]) { should eq("/") }
    its([:ssl]) { should be_false }
  end
end

