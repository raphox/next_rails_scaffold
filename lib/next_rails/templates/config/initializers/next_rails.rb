# frozen_string_literal: true

require "next_rails"

NextRails.setup do |config|
  config.generators do |g|
    g.helper :next_rails
  end
end
