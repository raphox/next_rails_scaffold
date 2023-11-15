# frozen_string_literal: true

module Rails
  class NextRailsGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    NODE_REQUIRED_VERSION = ">= 18.17.0"
    YARN_VERSION = "1.22.19"
    NEXT_VERSION = "14.0.2"
    NODULES_MODULES = [
      "@hookform/resolvers",
      "@tanstack/react-query",
      "axios",
      "react-hook-form",
      "zod"
    ].freeze

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

    # Check Javascript depencies and create a new Next.js project, install the the usefull packages and create the
    # scaffold code for frontend application.
    def create_frontend_project
      check_node!
      append_gitignore!

      empty_directory "frontend"

      inside("frontend") do
        create_next_app!

        install_hygen!
        install_dependencies!

        run("npx hygen generate scaffold #{name} #{mapped_attributes.join(" ")}")
        run("yarn build")
      end
    end

    private

    def check_node!
      node_version = run("node --version", capture: true).gsub(/[^0-9.]/, "")

      if Gem::Dependency.new("", NODE_REQUIRED_VERSION).match?("", node_version)
        say "Your Node version is '#{node_version}'", :green
      else
        say_error "You need to have a Node version '#{NODE_REQUIRED_VERSION}'", :red
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

    def install_dependencies!
      run("yarn add #{NODULES_MODULES.join(" ")}")
    end

    def mapped_attributes
      attributes.map { |attr| "#{attr.name}:#{attr.type}" }
    end

    # Make an entry in \Rails routing file <tt>config/routes.rb</tt>
    #
    #   route "root 'welcome#index'"
    #   route "root 'admin#index'", namespace: :admin
    #   route "root 'admin#index'", namespace: :admin, scope: '/api'
    def route(routing_code, namespace: nil, scope: nil)
      namespace = Array(namespace)
      namespace_pattern = route_namespace_pattern(namespace)
      routing_code = namespace.reverse.reduce(routing_code) do |code, name|
        "namespace :#{name} do\n#{rebase_indentation(code, 2)}end"
      end

      scope = Array(scope)
      routing_code = scope.reverse.reduce(routing_code) do |code, name|
        "scope '#{name}' do\n#{rebase_indentation(code, 2)}end"
      end

      log :route, routing_code

      in_root do
        if namespace_match = match_file("config/routes.rb", namespace_pattern)
          base_indent, *, existing_block_indent = namespace_match.captures.compact.map(&:length)
          existing_line_pattern = /^ {,#{existing_block_indent}}\S.+\n?/
          routing_code = rebase_indentation(routing_code, base_indent + 2).gsub(existing_line_pattern, "")
          namespace_pattern = /#{Regexp.escape namespace_match.to_s}/
        end

        inject_into_file "config/routes.rb", routing_code, after: namespace_pattern, verbose: false, force: false

        if behavior == :revoke && namespace.any? && namespace_match
          empty_block_pattern = /(#{namespace_pattern})((?:\s*end\n){1,#{namespace.size}})/
          gsub_file "config/routes.rb", empty_block_pattern, verbose: false, force: true do |matched|
            beginning, ending = empty_block_pattern.match(matched).captures
            ending.sub!(/\A\s*end\n/, "") while !ending.empty? && beginning.sub!(/^ *namespace .+ do\n\s*\z/, "")
            beginning + ending
          end
        end
      end
    end

    def exit_on_failure?
      true
    end
  end
end
