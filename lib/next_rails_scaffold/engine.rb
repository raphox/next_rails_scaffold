# frozen_string_literal: true

module NextRailsScaffold
  class Engine < ::Rails::Engine
    isolate_namespace NextRailsScaffold
    config.eager_load_namespaces << NextRailsScaffold
  end
end
