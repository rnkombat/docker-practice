class Api::V1::TopicsController < ApplicationController
  def index
    topics = Topic.order(created_at: :desc)
    render json: topics
  end

  def show
    render json: Topic.find(params[:id])
  end

  def create
    topic = Topic.new(topic_params)
    if topic.save
      render json: topic, status: :created
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    Topic.find(params[:id]).destroy!
    head :no_content
  end

  private
  def topic_params
    params.require(:topic).permit(:title, :description)
  end
end
