FactoryBot.define do
  factory :user do
    nickname              { Faker::Lorem.characters(number: rand(3..16)) }
    birth_date            { Faker::Date.backward }
    gender_id             { Faker::Number.between(from: 1, to: 4) }
    sequence(:email) { |n| "test#{n}@example.com" }
    password              { '1aA' + Faker::Internet.password(min_length: 6, max_length: 18) }
    password_confirmation { password }
  end
end
