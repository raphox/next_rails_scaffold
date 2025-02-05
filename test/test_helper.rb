# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "rails"
require "rails/test_help"
require "debug"

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = "bin/test"

require_relative "../lib/next_rails_scaffold"
