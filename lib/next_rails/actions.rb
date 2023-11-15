# frozen_string_literal: true

module NextRails
  # Make an entry in Rails routing file <tt>config/routes.rb</tt>
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
      if (namespace_match = match_file("config/routes.rb", namespace_pattern))
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
end
