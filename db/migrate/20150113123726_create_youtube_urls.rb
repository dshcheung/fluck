class CreateYoutubeUrls < ActiveRecord::Migration
  def change
    create_table :youtube_urls do |t|
      t.string :title
      t.string :youtube_code
      t.timestamps
    end
    add_index :youtube_urls, :youtube_code
  end
end
