# frozen_string_literal: true

require_relative "next_rails_scaffold/actions"
require_relative "next_rails_scaffold/engine"
require_relative "next_rails_scaffold/version"

module NextRailsScaffold
  class Error < StandardError; end

  @@configured = false

  def self.configured? # :nodoc:
    @@configured
  end

  # Default way to setup Next Rails. Run rails generate next_rails_scaffold:install
  # to create a fresh initializer with all configuration values.
  def self.setup
    @@configured = true
    yield Rails.application.config
  end
end
