require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BooKPuT
  class Application < Rails::Application
    # --- ここから追加 ---
    config.active_support.yaml_column_permitted_classes = [Symbol, Hash, Array, Time]
    # YAMLのエイリアスをグローバルに許可する（Ruby 3.1+ / Psych 4+ 対策）
    YAML.config_extensions << ->(config) { config.aliases = true } if YAML.respond_to?(:config_extensions)
    # --- ここまで追加 ---
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
