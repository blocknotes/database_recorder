class HomeController < ApplicationController
  def index
    render json: Post.all
  end
end
