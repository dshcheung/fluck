class StaticPagesController < ApplicationController
  def index
    @links = YoutubeUrl.order(:title)
  end
end
