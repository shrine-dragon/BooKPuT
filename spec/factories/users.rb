FactoryBot.define do
  factory :user do
    nickname   { Faker::Name.initials(number: 3) }
    birth_date { Faker::Date.backward(days: 365 * 20) }
    gender_id  { Faker::Number.between(from: 1, to: 4) }
    sequence(:email) { |n| "test#{n}@example.com" }
    password   { '1aA' + Faker::Internet.password(min_length: 8, max_length: 16) }
    password_confirmation { password }

    after(:build) do |user|
      image_path = Rails.root.join('spec/fixtures', 'Zakky.png')

      # spec/fixtures に画像がない場合は、何もしない（no-imageになる）
      if File.exist?(image_path)
        user.image.attach(io: File.open(image_path), filename: 'Zakky.png',
                          content_type: 'image/png')
      end
    end
  end
end
