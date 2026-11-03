FactoryBot.define do
  factory :contact do
    name { Faker::Name.initials }
    sequence(:email) { |n| "test#{n}@example.com" }
    subject { Faker::Lorem.sentence }
    message { Faker::Lorem.sentence }
  end
end
