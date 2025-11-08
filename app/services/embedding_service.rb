# frozen_string_literal: true

class EmbeddingService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def embed(text)
    response = @client.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: text
      }
    )
    response.dig("data", 0, "embedding")
  rescue StandardError => e
    Rails.logger.error("Failed to create embedding: #{e.message}")
    nil
  end
end
