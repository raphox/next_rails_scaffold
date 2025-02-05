# frozen_string_literal: true

require "rails/generators/rails/scaffold/scaffold_generator"
require_relative "node_package_manager"

module NextRailsScaffold
  module Generators
    class ScaffoldGenerator < Rails::Generators::ScaffoldGenerator
      include ::NextRailsScaffold::Actions

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      class_option :package_manager, type: :string, desc: "Package manager to use for frontend project"
      class_option :skip_build, type: :boolean, default: false, desc: "Skip running Next.js build"
      class_option :skip_routes, type: :boolean, default: false, desc: "Skip adding resources to routes.rb"
      class_option :typescript, type: :boolean, default: true, desc: "Generate TypeScript scaffold"

      attr_accessor :selected_package_manager

      def initialize(args, *options) # :nodoc:
        super
        self.attributes = shell.base.attributes
      end

      def add_resource_route
        return if options[:actions].present? || options[:skip_routes]

        route "resources :#{file_name.pluralize}", namespace: regular_class_path, scope: "/api"
      end

      def create_root_folder
        empty_directory "frontend"
      end

      # Check Javascript dependencies and create a new Next.js project. Install the the useful packages and create the
      # scaffold code for frontend application.
      def create_frontend_project
        return say_status :remove, "skip frontend folder", :yellow if shell.base.behavior == :revoke

        append_gitignore!

        node_package_manager = NodePackageManager.new(shell)

        inside("frontend") do
          node_package_manager.check_node!
          node_package_manager.check_pm_version!
          node_package_manager.create_next_app!
          node_package_manager.install_hygen!

          return if Rails.env.test?

          selected_package_manager = node_package_manager.selected_package_manager
          language = File.exist?("tsconfig.json") ? "typescript" : "javascript"

          run("#{selected_package_manager.fetch} hygen scaffold #{language} #{name} #{mapped_attributes.join(" ")}")
          if !options[:skip_build] && !@prompt.no?("Do you want to build your Next.js project?")
            run("#{selected_package_manager.run} build")
          end
        end
      end

      private

      def append_gitignore!
        path = File.join(destination_root, ".gitignore")

        return unless File.exist?(path)

        rows = <<~HEREDOC

          # Ignoring node modules for Rails and Next.js projects
          node_modules/
        HEREDOC

        append_to_file path, rows
      end

      def mapped_attributes
        attributes.map { |attr| "#{attr.name}:#{attr.type}" }
      end
    end
  end
end
