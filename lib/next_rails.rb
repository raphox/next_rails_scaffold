# frozen_string_literal: true

require_relative "next_rails/version"

module NextRails
  class Error < StandardError; end

  @@configured = false

  def self.configured? #:nodoc:
    @@configured
  end

  # Default way to setup Next Rails. Run rails generate next_rails:install
  # to create a fresh initializer with all configuration values.
  def self.setup
    @@configured = true
    yield Rails.application.config
  end
end
