# frozen_string_literal: true

class Article < ApplicationRecord
  has_neighbors :embedding

  validates :url, presence: true, uniqueness: true
  validates :content, presence: true
end
