module SpecIntegrationHelper
  @@started = false
  def self.ensure_started
    return if @@started == true

    # Unnescessary?
    Fixtures::Loader.destroy!
    loader = Fixtures::Loader.new
    loader.load!

    @@started = true
  end

  def self.stop
    return unless @@started == true

    ## Unnescessary?
    Fixtures::Loader.destroy!

    @@started = false
  end
end

RSpec.configure do |config|
  config.before(:context, :integration) do
    SpecIntegrationHelper.ensure_started
  end

  config.after(:suite) do
    SpecIntegrationHelper.stop
  end
end
