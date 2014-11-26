
shared_examples_for "a default config" do
  subject { config }
  its(:results_routing_key) { should be_nil }
  its(:jobs_routing_key) { should be_nil }
  its(:job_timeout) { should eq(10.0)}
  its(:job_channel_prefetch) { should eq(128)}
  its(:worker_name) { should eq( ENV["HOSTNAME"] || Socket.gethostname || "unknown") }

  context :amqp do
    subject { config[:amqp] }
    its([:url]) { should eq(ENV['CIKL_RABBITMQ_URL'] || "amqp://guest:guest@localhost/%2Fcikl") }
  end
end

