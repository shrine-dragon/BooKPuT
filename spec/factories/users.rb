FactoryBot.define do
  factory :user do
    nickname { Faker::Name.initials(number: 3) } # もしFakerを入れていれば
    # ここが重要：n を使って test1, test2... と絶対に被らないようにする
    sequence(:email) { |n| "test#{n}_#{Time.now.to_i}@example.com" }
    password { "PassWord123" }
    password_confirmation { password }
    birth_date { "1990-01-01" }
    gender_id { 2 }
  end
end
