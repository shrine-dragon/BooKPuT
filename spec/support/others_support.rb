module OtherSupport
  extend ActiveSupport::Concern

  included do

  end

  def image_test(image_text)
    # 任意項目である画像をアップロードできることを確認する
    image_path = Rails.root.join('spec/fixtures/Doflamingo.png')
    attach_file(image_text, image_path)
    # プレビュー画像が表示されることを確認する
    expect(page).to have_selector('.upload-image-list img')

    # 削除ボタンが表示されていることを確認（画像の検証ツールに見えるボタン）
    expect(page).to have_selector('.delete-image-btn', text: '削除')
    # 画像を一度削除し、画像と削除ボタンが消えていることを確認する
    if has_link?('削除')
      click_link '削除'
      expect(page).to have_no_selector('.upload-image-list img')
      # 一度削除した画像を再度アップロードできることを確認する
      attach_file(image_text, image_path)
    end
  end
end