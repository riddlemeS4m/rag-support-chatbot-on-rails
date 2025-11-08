# frozen_string_literal: true

class RagQueryService
  def initialize
    @embedder = EmbeddingService.new
    @openai_client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def call(query)
    # 1. Embed the query
    query_embedding = @embedder.embed(query)
    return { error: "Failed to embed query" } unless query_embedding

    # 2. Find similar articles
    similar_articles = Article.nearest_neighbors(
      :embedding,
      query_embedding,
      distance: "cosine"
    ).limit(3)

    return { answer: "I couldn't find any relevant articles to answer your question." } if similar_articles.empty?

    # 3. Build context from articles
    context = similar_articles.map do |article|
    "Title: #{article.title}\n\n#{article.content}"
    end.join("\n\n---\n\n")

    # 4. Generate answer with GPT
    answer = generate_answer(query, context)

    {
      answer: answer,
      sources: similar_articles.map { |a| { title: a.title, url: a.url } }
    }
  end

  private

  def generate_answer(query, context)
    prompt = <<~PROMPT
    You are a helpful QuantHub support assistant. Answer the user's question based on the following support articles.

    Support Article Context:
    #{context}

    User Question: #{query}

    Provide a clear, helpful answer based on the context above. If the context doesn't contain enough information to fully answer the question, say so and provide what information you can.
    PROMPT

    response = @openai_client.chat(
      parameters: {
        model: "gpt-4o-mini",  # Cheaper and fast, or use "gpt-4o" for better quality
        messages: [{ role: "user", content: prompt }],
        max_tokens: 1000
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue StandardError => e
    Rails.logger.error("Failed to generate answer: #{e.message}")
    "I'm sorry, I encountered an error generating a response."
  end
end
