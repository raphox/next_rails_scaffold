# frozen_string_literal: true

module NextRailsScaffold
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy NextRailsScaffold default files"
      source_root File.expand_path("templates", __dir__)

      def copy_config
        template "config/initializers/next_rails_scaffold.rb"
      end
    end
  end
end
