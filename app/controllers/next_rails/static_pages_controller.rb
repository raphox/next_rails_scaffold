# frozen_string_literal: true

module NextRails
  class StaticPagesController < ApplicationController
    STATIC_FILES_PATH = Rails.root.join("public").to_s

    def index
      send_file file_path, type: "text/html", disposition: "inline"
    rescue ActionController::ResourceNotFound
      send_file File.join(STATIC_FILES_PATH, "404.html"), type: "text/html", disposition: "inline", status: 404
    rescue StandardError => e
      Rails.logger.error "StaticPagesController (#{e.class}): #{e.message}"
      raise e
    end

    private

    def file_path
      path = params.require(:file_path)

      raise ActionController::ResourceNotFound, "Not Found" unless File.exist?(path)
      raise ActionController::RoutingError, "Forbidden" unless path.start_with?(STATIC_FILES_PATH)

      path
    end
  end
end
