ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
require 'logger'

require "yaml"
module YAML
  class << self
    alias_method :original_safe_load, :safe_load
    def safe_load(yaml, **kwargs)
      original_safe_load(yaml, **kwargs.merge(aliases: true))
    end
  end
end

p YAML.load <<~EOT, aliases: true
  a: &foo 1
  b: *foo
EOT