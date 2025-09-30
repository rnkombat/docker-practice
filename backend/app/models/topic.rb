class Topic < ApplicationRecord
  has_many :posts, dependent: :destroy
  validates :title, presence: true

  def check_limit_and_lock!
    user_posts = posts.where(system: false).count
    return if user_posts < 50
    transaction do
      update!(locked: true)
      unless posts.where(system: true).where("content LIKE ?", "%上限に達した%").exists?
        posts.create!(content: "このスレッドは上限に達したので新しいスレッドを立ててください", system: true)
      end
    end
  end
end
