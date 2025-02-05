# frozen_string_literal: true

require "test_helper"
require "generators/next_rails_scaffold/scaffold_generator"

module NextRailsScaffold
  module Generators
    class TestScaffoldGenerator < Rails::Generators::TestCase
      tests ScaffoldGenerator
      destination File.expand_path("../../../../tmp", __dir__)
      setup :prepare_destination

      arguments %w[message title:string content:text]

      def create_rails_app_structure
        FileUtils.mkdir_p(File.join(destination_root, "config"))
        File.write(File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend")
      end

      test "generates view templates" do
        create_rails_app_structure
        run_generator %w[message title:string content:text --package_manager=npm --skip_build]

        %w[index edit new show _form _message].each do |view|
          assert_file "app/views/messages/#{view}.html.erb"
        end

        assert_file "frontend/_templates/scaffold/setup.sh"
        assert_file "frontend/src/pages/index.tsx"
      end
    end
  end
end
