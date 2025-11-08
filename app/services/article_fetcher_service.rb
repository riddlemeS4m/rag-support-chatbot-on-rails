# frozen_string_literal: true

require "nokogiri"
require "open-uri"

class ArticleFetcherService
  SITEMAP_URL = "https://support.quanthub.com/sitemap.xml"

  def fetch_article_urls
    doc = Nokogiri::XML(URI.open(SITEMAP_URL))
    doc.remove_namespaces!

    doc.xpath("//loc").map(&:text).select do |url|
      url.include?("/knowledge/") &&
      !url.include?("kb-search") &&
      !url.include?("kb-404") &&
      !url.end_with?("/knowledge")
    end
  end

  def fetch_article(url)
    doc = Nokogiri::HTML(URI.open(url))

    {
      url: url,
      title: extract_title(doc),
      content: extract_content(doc)
    }
  rescue StandardError => e
    Rails.logger.error("Failed to fetch #{url}: #{e.message}")
    nil
  end

  private

  def extract_title(doc)
    doc.css("#hs_cos_wrapper_kb-article-module-3_ h1, article.knowledgebase-post h1").first&.text&.strip ||
    doc.css("title").first&.text&.strip ||
    "Untitled"
  end

  def extract_content(doc)
    article = doc.css("article.knowledgebase-post").first

    return fallback_content(doc) unless article

    article.css("script, style, nav, header, footer, .hs-kb-breadcrumb-container,
                 .hs-kb-sidebar, .hs-kb-feedback, .hs-kb-related-articles,
                 .header, .footer").remove

    content_div = article.css(".hs_cos_wrapper_type_inline_richtext_field,
                               #hs_cos_wrapper_kb-article-module-5_").first

    if content_div
      content_div.text.gsub(/\s+/, " ").strip
    else
      article.text.gsub(/\s+/, " ").strip
    end
  end

  def fallback_content(doc)
    doc.css("body").text.gsub(/\s+/, " ").strip
  end
end
