class Api::V1::PostsController < ApplicationController
  before_action :set_topic

  def index
    posts = @topic.posts.order(created_at: :asc).page(params[:page])
    render json: {
      topic_id: @topic.id,
      posts: posts,
      total_pages: posts.total_pages,
      current_page: posts.current_page
    }
  end

  def create
    @topic.check_limit_and_lock!
    if @topic.locked
      render json: { errors: ["このスレッドは上限に達しています"] }, status: :unprocessable_entity and return
    end

    post = @topic.posts.build(post_params.merge(system: false))
    if post.save
      @topic.check_limit_and_lock!
      render json: post, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def post_params
    params.require(:post).permit(:content)
  end
end
