# frozen_string_literal: true

require "tty-prompt"

PackageManager = Struct.new(:fetch, :run, :add, :lock_file, :version) do
  def to_s = run.split.first
end

module Rails
  class NextRailsScaffoldGenerator < Rails::Generators::NamedBase
    include ::NextRailsScaffold::Actions

    source_root File.expand_path("templates", __dir__)

    PACKAGE_MANAGERS = {
      "npm" => PackageManager.new("npx", "npm run", "npm install", "package-lock.json"),
      "yarn" => PackageManager.new("yarn dlx", "yarn", "yarn add", "yarn.lock"),
      "pnpm" => PackageManager.new("pnpm dlx", "pnpm", "pnpm add", "pnpm-lock.yaml"),
      "bun" => PackageManager.new("bunx", "bun run", "bun add", "bun.lock.json")
    }.freeze
    NODE_REQUIRED_VERSION = ENV.fetch("NODE_REQUIRED_VERSION", ">= 18.20")
    NEXT_VERSION = ENV.fetch("NEXT_VERSION", "15.1.6")

    argument :attributes, type: :array, default: [], banner: "field:type field:type"
    class_option :package_manager, type: :string, desc: "Package manager to use for frontend project"
    class_option :skip_build, type: :boolean, default: false, desc: "Skip running Next.js build"
    class_option :skip_routes, type: :boolean, default: false, desc: "Skip adding resources to routes.rb"

    attr_accessor :selected_package_manager

    def initialize(args, *options) # :nodoc:
      super

      @prompt = TTY::Prompt.new

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
      return if options[:actions].present? || options[:skip_routes]

      route "resources :#{file_name.pluralize}", namespace: regular_class_path, scope: "/api"
    end

    # Check Javascript dependencies and create a new Next.js project. Install the the useful packages and create the
    # scaffold code for frontend application.
    def create_frontend_project
      return say_status :remove, "skip frontend folder", :yellow if shell.base.behavior == :revoke

      append_gitignore!

      empty_directory "frontend"

      inside("frontend") do
        check_node!
        check_pm_version!
        create_next_app!
        install_hygen!

        language = File.exist?("tsconfig.json") ? "typescript" : "javascript"

        run("#{selected_package_manager} hygen scaffold #{language} #{name} #{mapped_attributes.join(" ")}")
        if !options[:skip_build] && !@prompt.no?("Do you want to build your Next.js project?")
          run("#{selected_package_manager.run} build")
        end
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

    def check_pm_version!
      package_manager = shell.base.options[:package_manager]

      unless package_manager
        PACKAGE_MANAGERS.each do |manager, details|
          if File.exist?(details.lock_file)
            package_manager = manager
            break
          end
        end
      end

      until PACKAGE_MANAGERS.keys.include?(package_manager)
        puts "Invalid package manager" unless package_manager.nil?

        package_manager = @prompt.select("Which package manager do you want to use?", PACKAGE_MANAGERS.keys)
      end

      self.selected_package_manager = PACKAGE_MANAGERS[package_manager]

      selected_package_manager.version = run("#{selected_package_manager} --version", capture: true).gsub(/[^0-9.]/, "")
      log :package_manager, "Using #{selected_package_manager} version '#{selected_package_manager.version}'"
    end

    def append_gitignore!
      rows = <<~HEREDOC

        # Ignoring node modules for Rails and Next.js projects
        node_modules/
      HEREDOC

      append_to_file ".gitignore", rows
    end

    def create_next_app!
      return if File.exist?("package.json")

      run(
        "#{selected_package_manager.fetch} create-next-app@#{NEXT_VERSION} . " \
        "--no-app --src-dir --import-alias \"@/*\""
      )

      if selected_package_manager.to_s == "yarn" &&
         Gem::Dependency.new("", ">= 2.0").match?("", selected_package_manager.version)
        run("yarn config set nodeLinker node-modules")
      end
    end

    def install_hygen!
      return if Dir.exist?("_templates")

      run("#{selected_package_manager.add} -D hygen hygen-add")
      run("#{selected_package_manager} hygen-add next-rails-scaffold")
    end

    def mapped_attributes
      attributes.map { |attr| "#{attr.name}:#{attr.type}" }
    end

    def exit_on_failure?
      true
    end
  end
end
