# frozen_string_literal: true

Rails.application.routes.draw do
  parameter_regex = /\[([a-zA-Z0-9_-]+)\]/
  static_files_path = Rails.root.join("public").to_s
  static_files = File.join(static_files_path, "**", "index.html")

  Dir.glob(static_files).each do |path|
    next unless path.match?(parameter_regex)

    route = path[%r{#{Regexp.escape(static_files_path)}(.*)/index.html}, 1]
    route = route.gsub(parameter_regex, ':\1')

    get route, to: "next_rails_scaffold/static_pages#index", file_path: path
  end
end
