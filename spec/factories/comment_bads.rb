FactoryBot.define do
  factory :comment_bad do
    association :user
    association :comment
  end
end
