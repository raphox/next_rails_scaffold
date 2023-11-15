# frozen_string_literal: true

require "next_rails"

NextRails.setup do |config|
  config.generators do |g|
    g.api_only = true
    g.resource_route false
    g.helper :next_rails
  end
end
