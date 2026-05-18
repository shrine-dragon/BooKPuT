require 'rails_helper'

RSpec.describe 'コメント投稿', type: :system do
  context 'コメントを投稿できる時' do
    it 'book投稿者以外のログインユーザーはコメント投稿ができる', js: true do
      # user2でログインする
      login_as user2
      # 投稿詳細ページに遷移する
      visit_book_path

      # コメントフォームが存在していることを確認する
      expect(page).to have_selector('.comment-form-text')
      # コメントフォームにテキストを入力する
      fill_in 'text', with: comment.text
      # 同時にコメント送信ボタンが表示されていることを確認する
      expect(page).to have_selector('.submit-comment-btn', visible: true)
      # コメントを送信するとCommentモデルのカウントが1上がることを確認する
      expect do
        scroll_display('.submit-comment-btn')
        sleep 0.5
      end.to change { Comment.count }.by(1)

      # コメントリストが更新され、投稿したコメントの内容や投稿時刻が表示されていることを確認する
      expect(page).to have_current_path(book_path(book))
      expect(page).to have_content('コメントを投稿しました')
      expect(page).to have_content('コメント 1')
      expect(page).to have_no_content('コメントはありません')
      
      check_comment_info
    end
  end

  context 'コメントを投稿できない時' do
    it '未ログインユーザーはコメントできない' do
      not_log_in_user
      # 投稿詳細ページに遷移する
      visit_book_path
      # 投稿詳細ページにコメントフォームが存在していないことを確認する
      expect(page).to have_no_selector('.comment-form-text')
    end
    
    it 'book投稿者は自身に投稿に対してコメントできない' do
      # user1でログインする
      login_as user1
      # 投稿詳細ページに遷移する
      visit_book_path
      # 投稿詳細ページにコメントフォームなどが存在していないことを確認する
      expect(page).to have_no_selector('.comment-form-text')
      expect(page).to have_no_selector('.user-image.post-comment')
      expect(page).to have_no_selector('.user-image.post-comment')
    end
  end
end

RSpec.describe 'コメント削除', type: :system do
  let!(:comment) { FactoryBot.create(:comment, user: user2, book: book) }

  context 'コメントを削除できる時' do
    it 'コメント投稿者は自身のコメントを削除できる', js: true do
      login_as user2
      visit_book_path
      check_comment_info

      # コメントの下に削除ボタンが存在することを確認する
      find('.js-destroy-comment-trigger', text: '削除').click

      # 削除ボタンを押すと最終確認の削除用モーダルが表示されることを確認する
      expect(page).to have_selector('.modal.final-action.destroy-comment')

      # コメントを削除するとCommentモデルのカウントが1下がることを確認する
      expect(page).to have_content('このコメントを削除しますか？')
      expect do
        click_on('削除する')
        sleep 0.5
      end.to change { Comment.count }.by(-1)

      # 投稿詳細ページにコメントが存在しないことを確認する
      expect(page).to have_current_path(book_path(book))
      expect(page).to have_content('コメントを削除しました')

      expect(page).to have_no_content(comment.text)
    end
  end

  context 'コメントを削除できない時' do
    it '未ログインユーザーはコメント自体を削除できない' do
      not_log_in_user
      visit_book_path
      check_comment_info

      # コメントの下に｢削除ボタン｣が存在しないことを確認する
      expect(page).to have_no_selector('.js-destroy-comment-trigger', text: '削除')
    end

    it 'コメント投稿者以外のログインユーザーは他者のコメントを削除できない' do
      [user1, user3].each do |user|
        login_as user
        visit_book_path
        check_comment_info
        expect(page).to have_no_selector('.js-destroy-comment-trigger', text: '削除')
      end
    end

    it 'コメント投稿者本人でも｢削除するボタン以外の要素を押すとコメントを削除できない｣' do
      login_as user2
      visit_book_path
      check_comment_info

      expect(page).to have_selector('.js-destroy-comment-trigger', text: '削除')

      selectors = ['.no-action.btn-text', '.fa-xmark', '#modal-overlay']

      selectors.each do |_selector|
        find('.js-destroy-comment-trigger', text: '削除').click
        expect(page).to have_selector('.modal.final-action.destroy-comment', visible: true, wait: 5)
        expect do
          if _selector == '#modal-overlay'
            # 【ポイント】重なり合っている背景要素は、JavaScriptで強制的にクリックを発火させる
            page.execute_script("document.querySelector('#modal-overlay').click();")
          else
            # 通常のボタン（キャンセルや×ボタン）は普通にクリック
            find(_selector).click
          end

          expect(page).to have_no_selector('.modal.final-action.destroy-comment', wait: 5)
        end.not_to(change { Comment.count })
        
        sleep 0.1
      end
    end
  end
end