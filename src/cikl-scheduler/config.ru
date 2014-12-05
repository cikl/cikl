require 'sidekiq'

if ENV['SCHEDULER_REDIS_URL'].nil?
  raise "Missing required environment variable: 'SCHEDULER_REDIS_URL'"
end

Sidekiq.configure_client do |config|
  config.redis = { 
    :size => 1,
    :url => ENV['SCHEDULER_REDIS_URL']
  }
end

require 'sidekiq/web'
run Sidekiq::Web
