# frozen_string_literal: true

require_relative "lib/next_rails_scaffold/version"

Gem::Specification.new do |spec|
  spec.name = "next_rails_scaffold"
  spec.version = NextRailsScaffold::VERSION
  spec.authors = ["Raphael Araújo"]
  spec.email = ["raphox.araujo@gmail.com"]

  spec.summary = <<~HEREDOC
    The `next_rails_scaffold` gem enhances the default Ruby on Rails scaffold generator by seamlessly integrating with Next.js, a React framework. This gem automates the process of scaffolding a Rails application along with a corresponding frontend directory containing a Next.js application. The generated Next.js app includes all necessary pages and components, leveraging the power of page routing for a smooth and organized development experience.
  HEREDOC
  spec.description = <<~HEREDOC
    The `next_rails_scaffold` gem is a powerful extension to the standard Ruby on Rails scaffold generator. It streamlines the development workflow by not only creating the backend structure with Rails but also automating the setup of a frontend directory using Next.js. Upon running the scaffold generator, this gem intelligently generates a Next.js application within the specified frontend directory.

    The generated Next.js app follows best practices, including a structured page routing system, ensuring that each resource created by the scaffold has its corresponding page and components. This integration enables developers to seamlessly transition between Rails backend and Next.js frontend development, fostering a cohesive and efficient development environment.

    Key Features:

    - **Automatic Frontend Setup:** The gem automates the creation of a frontend directory within the Rails project, ready for Next.js development.
    - **Page Routing Integration:** All scaffolded resources come with their own pages and components, organized using Next.js' page routing system.
    - **Effortless Transition:** Developers can seamlessly switch between Rails backend and Next.js frontend development within the same project.
    - **Boosted Productivity:** Accelerate development by eliminating the manual setup of frontend components and pages, allowing developers to focus on building features.

    Integrate `next_rails_scaffold` into your Ruby on Rails projects to enjoy a streamlined, organized, and efficient full-stack development experience.
  HEREDOC
  spec.homepage = "https://github.com/raphox/next-rails#readme"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/raphox/next-rails"
  spec.metadata["changelog_uri"] = "https://github.com/raphox/next-rails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.1.2"
  spec.add_dependency "tty-prompt", "~> 0.23.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
