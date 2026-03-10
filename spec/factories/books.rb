FactoryBot.define do
  factory :book do
    title       { Faker::Book.title }
    category_id { Faker::Number.between(from: 1, to: 12) }

    association :user

    after(:build) do |book|
      book.book_contents << build(:book_content, book: book)
    end

    after(:build) do |book|
      book.image.attach(io: File.open('app/assets/images/Doflamingo.png'), filename: 'Doflamingo.png', content_type: 'image/png')
    end
  end
end
