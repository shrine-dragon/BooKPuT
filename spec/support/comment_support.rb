module CommentSupport
  extend ActiveSupport::Concern

  included do
    let(:user1)   { FactoryBot.create(:user) }
    let(:user2)   { FactoryBot.create(:user) }
    let(:user3)   { FactoryBot.create(:user) }

    let!(:book)   { FactoryBot.create(:book, user: user1) }
    let(:comment) { FactoryBot.create(:comment, user: user2, book: book) }
  end

  def check_comment_info
    new_comment = Comment.last

    expect(page).to have_selector('.user-image.posted-comment')
    expect(page).to have_selector('.user-nickname.posted-comment')
    expect(page).to have_content(new_comment.text)
    expect(page).to have_content(new_comment.created_at.strftime('%Y/%m/%d %H:%M:%S'))
  end

  def final_action_of_comment_operation(
    selector_name,
    btn_text,
    warning_text,
    final_action_text,
    model_name,
    number,
    flash_message
  )
    visit_book_path
    check_comment_info

    # コメントの下にボタンが存在することを確認する
    find(".js-#{selector_name}-trigger", text: btn_text).click

    # ボタンを押すと最終確認のモーダルが表示されることを確認する
    expect(page).to have_selector(".modal.final-action.#{selector_name}")

    # モデルのレコードの数が変化することを確認する
    expect(page).to have_content(warning_text)
    expect do
      click_on(final_action_text)
      sleep 0.5
    end.to change { model_name.count }.by(number)

    # 投稿詳細ページに遷移し、フラッシュメッセージが表示されていることを確認する
    expect(page).to have_current_path(book_path(book))
    expect(page).to have_content(flash_message)
  end

  def close_modal_final_action(selector_name, btn_text)
    expect(page).to have_selector(".js-#{selector_name}-trigger", text: btn_text)

    selectors = ['.no-action.btn-text', '.fa-xmark', '#modal-overlay']

    selectors.each do |_selector|
      find(".js-#{selector_name}-trigger", text: btn_text).click
      expect(page).to have_selector(".modal.final-action.#{selector_name}", visible: true, wait: 5)
      expect do
        if _selector == '#modal-overlay'
          # 【ポイント】重なり合っている背景要素は、JavaScriptで強制的にクリックを発火させる
          page.execute_script("document.querySelector('#modal-overlay').click();")
        else
          # 通常のボタン（キャンセルや×ボタン）は普通にクリック
          find(_selector).click
        end

        expect(page).to have_no_selector(".modal.final-action.#{selector_name}", wait: 5)
      end.not_to(change { Comment.count })

      sleep 0.1
    end
  end
end
