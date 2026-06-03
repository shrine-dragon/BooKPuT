# 2つ以上のテストコードファイルで使用するメソッドを記述

module OtherSupport
  extend ActiveSupport::Concern

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

  def scroll_display(selector_or_text)
    # セレクタ（#や.）でなければテキストとして探す
    element = if selector_or_text.start_with?('#', '.')
                find(selector_or_text, wait: 10, visible: :all)
              else
                # text: selector_or_text を match: :first にするか、
                # リンク内のテキストが含まれているものを探すように変更
                find('a', text: selector_or_text, wait: 10, visible: :all)
              end

    execute_script('arguments[0].scrollIntoView({block: "center"});', element)
    sleep 0.5
    # 強制的にクリック
    execute_script('arguments[0].click();', element)
  end

  def visit_my_page
    # ｢マイページ｣ボタンをクリックし、マイページに遷移していることを確認する
    click_on('マイページ')
    expect(page).to have_current_path(user_path(user), wait: 15)
  end

  def cannot_click_valuation_btn(selector_name_one, selector_name_two, model)
    # ボタン自体は存在するが、カーソルを合わせてもポインターにならないことを確認する
    expect(page).to have_selector(".fa-regular.fa-thumbs-#{selector_name_one}.posted-#{selector_name_two}.disabled-icon")
    expect(page).to have_no_selector(".fa-regular.fa-thumbs-#{selector_name_one}.hovers.posted-#{selector_name_two}")

    # ボタンを押してもモデルのカウントは変化しないことを確認する
    expect do
      find(".fa-regular.fa-thumbs-#{selector_name_one}.posted-#{selector_name_two}.disabled-icon").click
      sleep 0.5
    end.to change { model.count }.by(0)
  end
end
