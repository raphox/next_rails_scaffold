# frozen_string_literal: true

module Rails
  class NextRailsScaffoldGenerator < Rails::Generators::NamedBase
    include ::NextRailsScaffold::Actions

    source_root File.expand_path("templates", __dir__)

    NODE_REQUIRED_VERSION = ">= 18.18.0"
    YARN_VERSION = "4.5.3"
    NEXT_VERSION = "15.0.3"

    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    def initialize(args, *options) # :nodoc:
      super
      self.attributes = shell.base.attributes
    end

    # Properly nests namespaces passed into a generator
    #
    #   $ bin/rails generate resource admin/users/products
    #
    # should give you
    #
    #   scope '/api' do
    #     namespace :admin do
    #       namespace :users do
    #         resources :products
    #       end
    #     end
    #   end
    def add_resource_route
      return if options[:actions].present?

      route "resources :#{file_name.pluralize}", namespace: regular_class_path, scope: "/api"
    end

    # Check Javascript depencies and create a new Next.js project. Install the the usefull packages and create the
    # scaffold code for frontend application.
    def create_frontend_project
      return say_status :remove, "skip frontend folder", :yellow if shell.base.behavior == :revoke

      check_node!
      append_gitignore!

      empty_directory "frontend"

      inside("frontend") do
        create_next_app!
        install_hygen!

        language = File.exist?("tsconfig.json") ? "typescript" : "javascript"

        run("npx hygen scaffold #{language} #{name} #{mapped_attributes.join(" ")}")
        run("yarn build")
      end
    end

    private

    def check_node!
      node_version = run("node --version", capture: true).gsub(/[^0-9.]/, "")

      if Gem::Dependency.new("", NODE_REQUIRED_VERSION).match?("", node_version)
        log :node_version, "Your Node version is '#{node_version}'"
      else
        say_status :node_version, "You need to have a Node version '#{NODE_REQUIRED_VERSION}'", :red
        abort
      end
    end

    def append_gitignore!
      rows = <<~HEREDOC

        # Ingoring node modules for Rails and Next.js projects
        node_modules/
      HEREDOC

      append_to_file ".gitignore", rows
    end

    def create_next_app!
      return if File.exist?("package.json")

      run("npm install --global yarn@#{YARN_VERSION}")
      run("yarn global add create-next-app@#{NEXT_VERSION}")
      run("yarn create next-app . --no-app --src-dir --import-alias \"@/*\"")
    end

    def install_hygen!
      return if Dir.exist?("_templates")

      run("yarn add -D hygen hygen-add")
      run("npx hygen-add next-rails-scaffold")
    end

    def mapped_attributes
      attributes.map { |attr| "#{attr.name}:#{attr.type}" }
    end

    def exit_on_failure?
      true
    end
  end
end
