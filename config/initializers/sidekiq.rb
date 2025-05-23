require "sidekiq"

redis_config = { url: ENV.fetch("REDIS_URL", "redis://redis:6379/0") }

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.logger.level = Logger::INFO
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  # Client configuration if needed
end
