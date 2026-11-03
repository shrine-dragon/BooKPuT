FactoryBot.define do
  factory :book_good do
    association :user
    association :book
  end
end
