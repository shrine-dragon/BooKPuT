FactoryBot.define do
  factory :reported_book do
    association :user
    association :book
  end
end
