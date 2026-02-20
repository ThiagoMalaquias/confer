require_relative "boot"

require "rails/all"
require "active_job/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Confer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    I18n.available_locales = [:en, :'pt-BR']

    config.i18n.default_locale = :'pt-BR'
    config.time_zone = 'Brasilia'
    config.active_storage.queue = :active_storage

    ActiveStorage::Engine.config
                         .active_storage
                         .content_types_to_serve_as_binary
                         .delete('image/svg+xml')
  end
end
