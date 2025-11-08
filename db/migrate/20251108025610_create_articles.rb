class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :url, null: false
      t.string :title
      t.text :content
      t.vector :embedding, limit: 1536  # OpenAI text-embedding-3-small dimensions

      t.timestamps
    end

    add_index :articles, :url, unique: true
  end
end
