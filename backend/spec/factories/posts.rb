FactoryBot.define do
  factory :post do
    association :topic
    content { "Sample content" }
    system { false }
  end
end
