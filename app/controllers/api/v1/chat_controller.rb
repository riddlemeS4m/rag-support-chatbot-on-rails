# frozen_string_literal: true

class Api::V1::ChatController < ApplicationController
  def create
    query = params[:message]

    if query.blank?
      return render json: { error: "Message cannot be blank" }, status: :unprocessable_entity
    end

    result = RagQueryService.new.call(query)

    if result[:error]
        render json: { error: result[:error] }, status: :unprocessable_entity
    else
        render json: {
        response: result[:answer],
        sources: result[:sources]
        }
    end
  rescue => e
    Rails.logger.error("Chat error: #{e.message}")
    render json: { error: "An error occurred processing your request" }, status: :internal_server_error
  end
end
