class DeletesController < ApplicationController
  def index
    test = YoutubeUrl.destroy_all
    render json: {success: true, deleted: test}
  end
end
