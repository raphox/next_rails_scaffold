# frozen_string_literal: true

require "open3"
require "tty-prompt"

module NextRailsScaffold
  module Generators
    NodePackageManagerStruct = Struct.new(:fetch, :run, :add, :lock_file, :version) do
      def to_s = run.split.first

      def available?
        version.present?
      end

      def version
        @version ||= NodePackageManager.get_version(to_s)
      end
    end

    NODE_REQUIRED_VERSION = ENV.fetch("NODE_REQUIRED_VERSION", ">= 18.20")
    NEXT_VERSION = ENV.fetch("NEXT_VERSION", "15.1.6")

    PACKAGE_MANAGERS = {
      "npm" => NodePackageManagerStruct.new("npx", "npm run", "npm install", "package-lock.json"),
      "yarn" => NodePackageManagerStruct.new("npx", "yarn", "yarn add", "yarn.lock"),
      "pnpm" => NodePackageManagerStruct.new("pnpm dlx", "pnpm", "pnpm add", "pnpm-lock.yaml"),
      "bun" => NodePackageManagerStruct.new("bunx", "bun run", "bun add", "bun.lock.json")
    }.freeze

    class NodePackageManager
      attr_reader :selected_package_manager

      def self.get_version(command)
        Open3.capture3(command, "--version").first.gsub(/[^0-9.]/, "")
      rescue Errno::ENOENT
        nil
      end

      def initialize(shell)
        @prompt = TTY::Prompt.new
        @shell = shell
      end

      def check_node!
        node_version = self.class.get_version("node")

        return if Gem::Dependency.new("", NODE_REQUIRED_VERSION).match?("", node_version)

        raise node_version ? "Your Node version is '#{node_version}'" : "Node not found"
      end

      def check_pm_version!
        package_manager = @shell.base.options[:package_manager]

        unless package_manager
          PACKAGE_MANAGERS.each do |manager, details|
            if File.exist?(details.lock_file)
              package_manager = manager
              break
            end
          end
        end

        until PACKAGE_MANAGERS.keys.include?(package_manager)
          raise "Invalid package manager" unless package_manager.nil?

          package_manager = @prompt.select(
            "Which package manager do you want to use?",
            PACKAGE_MANAGERS.keys.map { |pm| { name: pm, value: pm, disabled: !PACKAGE_MANAGERS[pm].available? } }
          )
        end

        @selected_package_manager = PACKAGE_MANAGERS[package_manager]
      end

      def create_next_app!
        return if File.exist?("package.json")

        use_typescript = @shell.base.options[:typescript] ? "--ts" : ""

        system(
          "#{selected_package_manager.fetch} create-next-app@#{NEXT_VERSION} . --use-#{selected_package_manager} " \
          "--no-app --src-dir --import-alias \"@/*\" #{use_typescript} #{Rails.env.test? ? "--yes" : ""}"
        )

        if selected_package_manager.to_s == "yarn" &&
           Gem::Dependency.new("", ">= 2.0").match?("", selected_package_manager.version)
          system("yarn config set nodeLinker node-modules")
        end
      end

      def install_hygen!
        return if Dir.exist?("_templates")

        hygen_add = "hygen-add@https://github.com/raphox/hygen-add"

        system("#{selected_package_manager.add} -D hygen #{hygen_add}")
        system("#{selected_package_manager.fetch} #{hygen_add} next-rails-scaffold --pm #{selected_package_manager}")
      end
    end
  end
end
