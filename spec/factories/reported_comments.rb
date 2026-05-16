FactoryBot.define do
  factory :reported_comment do
    text { Faker::Lorem.sentence }
    association :user
    association :comment
  end
end