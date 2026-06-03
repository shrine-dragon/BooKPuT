FactoryBot.define do
  factory :comment_good do
    association :user
    association :comment
  end
end
