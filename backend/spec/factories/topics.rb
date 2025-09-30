FactoryBot.define do
  factory :topic do
    sequence(:title) { |n| "Topic #{n}" }
    description { "Description" }
    locked { false }
  end
end
