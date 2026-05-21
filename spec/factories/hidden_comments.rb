FactoryBot.define do
  factory :hidden_comment do
    text { Faker::Lorem.sentence }
    association :user
    association :comment
  end
end
