# frozen_string_literal: true

class Rails::NextRailsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  NODE_REQUIRED_VERSION = ">= 18.17.0"
  YARN_VERSION = "1.22.19"
  NEXT_VERSION = "14.0.2"

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  def initialize(args, *options) # :nodoc:
    super
    self.attributes = shell.base.attributes
  end

  def create_frontend_project
    node_version = run("node --version", capture: true).gsub(/[^0-9.]/, "")

    if Gem::Dependency.new("", NODE_REQUIRED_VERSION).match?("", node_version)
      say "Your Node version is '#{node_version}'", :green
    else
      say_error "You need to have a Node version '#{NODE_REQUIRED_VERSION}'", :red
      abort
    end

    append_to_file ".gitignore", "\n# Ingoring node modules for Rails and Next.js projects\nnode_modules/\n"
    empty_directory "frontend"

    inside("frontend") do
      unless File.exist?("package.json")
        system("npm install --global yarn@#{YARN_VERSION}")
        system("yarn global add create-next-app@#{NEXT_VERSION}")
        run("yarn create next-app . --no-app --src-dir --import-alias \"@/*\"")
      end

      unless Dir.exist?("_templates")
        run("yarn add -D hygen hygen-add")
        run("npx hygen-add next-rails-scaffold")
      end

      run("yarn add axios @tanstack/react-query zod react-hook-form @hookform/resolvers")
      run("npx hygen generate scaffold #{name} #{mapped_attributes.join(" ")}")
    end
  end

  private

  def mapped_attributes
    attributes.map { |attr| "#{attr.name}:#{attr.type}" }
  end

  def exit_on_failure?
    true
  end
end
