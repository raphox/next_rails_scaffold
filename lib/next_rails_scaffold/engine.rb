# frozen_string_literal: true

require "rails"

module NextRailsScaffold
  class Engine < ::Rails::Engine
    isolate_namespace NextRailsScaffold
  end
end
