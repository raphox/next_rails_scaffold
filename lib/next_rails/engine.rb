# frozen_string_literal: true

module NextRails
  class Engine < ::Rails::Engine
    isolate_namespace NextRails
    config.eager_load_namespaces << NextRails
  end
end
