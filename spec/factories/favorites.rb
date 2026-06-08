FactoryBot.define do
  factory :favorite do
    association :user
    association :book
  end
end
