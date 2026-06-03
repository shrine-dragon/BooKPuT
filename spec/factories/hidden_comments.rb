FactoryBot.define do
  factory :hidden_comment do
    association :user
    association :comment
  end
end
