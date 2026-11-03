FactoryBot.define do
  factory :book_content do
    content { Faker::Lorem.sentence }
  end
end
