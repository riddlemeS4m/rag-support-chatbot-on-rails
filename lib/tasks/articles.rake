# frozen_string_literal: true

namespace :articles do
  desc "Sync all articles from support site"
  task sync: :environment do
    puts "Starting article sync..."

    fetcher = ArticleFetcherService.new
    embedder = EmbeddingService.new

    urls = fetcher.fetch_article_urls
    puts "Found #{urls.count} articles to sync"

    synced = 0
    skipped = 0

    urls.each_with_index do |url, i|
      print "\rProcessing #{i + 1}/#{urls.count}..."

      # Fetch article
      article_data = fetcher.fetch_article(url)
      next unless article_data

      # Skip if no content
      if article_data[:content].blank? || article_data[:content].length < 50
        skipped += 1
        next
      end

      # Create embedding
      embedding = embedder.embed(article_data[:content])
      next unless embedding

      # Store in database
      Article.find_or_create_by(url: article_data[:url]) do |article|
        article.title = article_data[:title]
        article.content = article_data[:content]
        article.embedding = embedding
      end

      synced += 1
      sleep(0.1) # Be nice to OpenAI's API
    end

    puts "\n\nSync complete!"
    puts "Synced: #{synced} articles"
    puts "Skipped: #{skipped} articles (no content)"
  end
end
