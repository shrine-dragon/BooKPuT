module CommentSupport
  extend ActiveSupport::Concern

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
    flash_message,
    comment_index: :first
  )
    # コメントリストの中で最新のコメントを指定する
    target_comment = all('.posted-comment-wrapper')[comment_index == :first ? 0 : -1]

    # コメントの下にボタンが存在することを確認する
    within(target_comment) do
      find(".js-#{selector_name}-trigger", text: btn_text).click
    end

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

    selectors = ['.no-action.btn-text', '.close-modal', '#modal-overlay']

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

  def increase_comments(comment_num)
    # コメントを10件まで増やす
    comment_num.times do |index|
      current_count = index + 1
      # フォームに毎回異なる文字を入力する
      fill_in 'comment[text]', with: "テストコメント（#{current_count}件目）"
      # 文字入力するたびにコメント送信ボタンが表示されることを確認する
      expect(page).to have_selector('.comment-btn.is-show', visible: true)
      find('.submit-comment-btn').click
      sleep 0.5

      # コメントを送信するとコメント総数が更新され、投稿したコメントがリストに存在していることを確認する
      expect(page).to have_no_selector('.empty-message.none-comment', text: 'コメントはありません')
      expect(page).to have_selector('.posted-comment-number', text: "コメント #{current_count}")
      expect(page).to have_content("テストコメント（#{current_count}件目）")

      if current_count <= 10
        # ｢もっと見る｣ボタンが非表示であることを確認する
        expect(page).to have_selector('.posted-comment-wrapper', count: current_count)
        expect(page).to have_no_selector('.view-more-comments-text', text: 'コメントをもっと見る')
      elsif current_count > 10
        # 「もっと見る」ボタンが表示されていることを確認する
        expect(page).to have_selector('.view-more-comments-text', text: 'コメントをもっと見る', visible: true)
        # コメントの表示件数は10件に制限されていることを確認する
        expect(page).to have_selector('.posted-comment-wrapper', count: 10)
        if current_count >= 21
          [20, 21].each do |num|
            find('.view-more-comments-text').click
            # コメントの表示件数は20件、21件と増えていることを確認する
            expect(page).to have_selector('.posted-comment-wrapper', count: num)
          end
          # コメントが21件表示されている状態で｢折りたたむ｣ボタンを押すと、コメントの表示件数が10件とデフォルトに戻っていることを確認する
          find('.hide-comments-text').click
          expect(page).to have_selector('.posted-comment-wrapper', count: 10)
        end
      end
    end
  end
end
