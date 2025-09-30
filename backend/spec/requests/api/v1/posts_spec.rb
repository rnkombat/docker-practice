# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Posts", type: :request do
  describe "GET /api/v1/topics/:topic_id/posts" do
    let(:topic) { create(:topic) }

    before do
      create(:post, topic: topic, content: "First post", created_at: 1.day.ago)
      create(:post, topic: topic, content: "Second post", created_at: 1.hour.ago)
    end

    it "returns posts ordered by creation time" do
      get api_v1_topic_posts_path(topic)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["topic_id"]).to eq(topic.id)
      expect(body["posts"].map { |post| post["content"] }).to eq(["First post", "Second post"])
      expect(body["total_pages"]).to be >= 1
      expect(body["current_page"]).to eq(1)
    end
  end

  describe "POST /api/v1/topics/:topic_id/posts" do
    let(:topic) { create(:topic) }

    it "creates a post when valid" do
      expect do
        post api_v1_topic_posts_path(topic), params: { post: { content: "Hello" } }
      end.to change { topic.posts.where(system: false).count }.by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["content"]).to eq("Hello")
      expect(topic.posts.where(system: true)).to be_empty
    end

    it "returns errors when content is blank" do
      expect do
        post api_v1_topic_posts_path(topic), params: { post: { content: "" } }
      end.not_to change { topic.posts.count }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Content can't be blank")
    end

    it "prevents posting once the topic is locked" do
      create_list(:post, 50, topic: topic, system: false)

      expect do
        post api_v1_topic_posts_path(topic), params: { post: { content: "Too much" } }
      end.not_to change { topic.posts.where(system: false).count }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("このスレッドは上限に達しています")
      expect(topic.reload.locked).to be true
      expect(topic.posts.where(system: true).where("content LIKE ?", "%上限に達した%")).to exist
    end
  end
end
