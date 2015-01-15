class YoutubeUrl < ActiveRecord::Base
  validates :youtube_code, uniqueness: true
end
