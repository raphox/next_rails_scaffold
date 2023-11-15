# frozen_string_literal: true

module NextRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy NextRails default files"
      source_root File.expand_path("templates", __dir__)

      def copy_config
        template "config/initializers/next_rails.rb"
      end
    end
  end
end
