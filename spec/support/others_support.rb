# 2つ以上のテストコードファイルで使用するメソッドを記述

module OtherSupport
  extend ActiveSupport::Concern

  included do
    before do
      @user = FactoryBot.create(:user)
    end
  end

  def image_test(file_name, image_text)
    # 任意項目である画像をアップロードできることを確認する
    image_path = Rails.root.join('spec/fixtures/' + file_name)

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

    # 正しくアップロードされているか、ファイル名で最終確認する
    expect(page).to have_selector('.preview-image', wait: 5)
  end

  def log_in_user_access_denied(path, no_exist_text)
    # ログインし、トップページへ移動する
    login_as(@user)
    visit root_path
    # URLを入力して、@userが移動できないpathへ直接アクセスしようとする
    visit path
    # トップページへ戻されていることを確認する
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_content(no_exist_text)
  end

  def not_log_in_user_access_denied(path, no_exist_text)
    # トップページへ移動する
    visit root_path
    # URLを入力して、未ログインユーザーが移動できないpathへ直接アクセスしようとする
    visit path
    # トップページへ戻されていることを確認する
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_content(no_exist_text)
    # ｢ログインが必要です｣というエラーメッセージとログインモーダルが表示されていることを確認する
    expect(page).to have_content('ログインが必要です')
    expect(page).to have_selector('.modal.log-in')
  end

  def visit_my_page
    # ｢マイページ｣ボタンをクリックし、マイページへ遷移していることを確認する
    click_on('マイページ')
    expect(page).to have_current_path(user_path(@user), wait: 15)
  end
end
