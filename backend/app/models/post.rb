class Post < ApplicationRecord
  attribute :system, :boolean, default: false

  belongs_to :topic

  validates :content, presence: true
end
