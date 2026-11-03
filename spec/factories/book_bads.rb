FactoryBot.define do
  factory :book_bad do
    association :user
    association :book
  end
end
