FactoryBot.define do
  factory :book do
    title       { Faker::Book.title }
    category_id { Faker::Number.between(from: 1, to: 9) }
    genre_ids do
      # 選択されたcategory_idに紐づくGenreをActiveHashから取得
      available_genres = Genre.where(category_id: category_id)

      # その中からランダムに3つ選び、IDを取り出して文字列の配列にする
      # （万が一ジャンルが3つ未満のカテゴリがあってもエラーにならないようsampleを使用）
      available_genres.sample(3).map { |g| g.id.to_s }
    end

    association :user

    after(:build) do |book|
      image_path = Rails.root.join('spec/fixtures', 'Momose-Akira-no-firstLove-failing.png')

      # spec/fixtures に画像がない場合は、何もしない（no-imageになる）
      if File.exist?(image_path)
        book.image.attach(io: File.open(image_path), filename: 'Momose-Akira-no-firstLove-failing.png',
                          content_type: 'image/png')
      end

      # まだ内容項目がない場合のみ、7つ作成する
      if book.book_contents.empty?
        7.times do |i|
          book.book_contents.build(content: "#{i + 1}番目の内容項目")
        end
      end
    end
  end
end
