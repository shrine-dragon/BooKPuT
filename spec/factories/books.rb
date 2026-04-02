FactoryBot.define do
  factory :book do
    title       { Faker::Book.title }
    category_id { Faker::Number.between(from: 1, to: 12) }
    genre_ids   {[Faker::Number.between(from: 1, to: 89)] }

    association :user

    after(:build) do |book|
      book.book_contents << build(:book_content, book: book)
    end
  end
end
