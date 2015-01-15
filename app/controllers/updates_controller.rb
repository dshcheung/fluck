class UpdatesController < ApplicationController
  def index
    render json: {success: true, data: YoutubeUrl.all}
  end
end
