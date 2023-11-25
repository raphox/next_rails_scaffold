# frozen_string_literal: true

NextRailsScaffold.setup do |config|
  config.generators do |g|
    g.api_only = true
    g.resource_route false
    g.helper :next_rails_scaffold
  end
end
