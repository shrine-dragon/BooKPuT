require 'rails_helper'

RSpec.describe 'コメント投稿', type: :system do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @book = FactoryBot.create(:book, user: @user1)
    @comment = FactoryBot.build(:comment)
  end

  context 'コメントを投稿できる時' do
    it 'book投稿者以外のログインユーザーはコメント投稿ができる', js: true do
      # user2でログインする
      login_as @user2

      # 投稿詳細ページに遷移する
      visit_book_path

      # コメントフォームが存在していることを確認する
      expect(page).to have_selector('.comment-form-text')
      # コメントフォームにテキストを入力する
      fill_in 'text', with: @comment.text
      # 同時にコメント送信ボタンが表示されていることを確認する
      expect(page).to have_selector('.submit-comment-btn', visible: true)
      # コメントを送信するとCommentモデルのカウントが1上がることを確認する
      expect do
        scroll_display('.submit-comment-btn')
        sleep 0.5
      end.to change { Comment.count }.by(1)

      # コメントリストが更新され、投稿したコメントの内容や投稿時刻が表示されていることを確認する
      expect(page).to have_current_path(book_path(@book))
      expect(page).to have_content('コメントを投稿しました')
      expect(page).to have_content('コメント 1')
      expect(page).to have_no_content('コメントはありません')
      
      new_comment = Comment.last

      expect(page).to have_selector('.user-image.posted-comment')
      expect(page).to have_selector('.user-nickname.posted-comment')
      expect(page).to have_content(new_comment.text)
      expect(page).to have_content(new_comment.created_at.strftime('%Y/%m/%d %H:%M:%S'))
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
      login_as @user1
      # 投稿詳細ページに遷移する
      visit_book_path
      # 投稿詳細ページにコメントフォームなどが存在していないことを確認する
      expect(page).to have_no_selector('.comment-form-text')
      expect(page).to have_no_selector('.user-image.post-comment')
      expect(page).to have_no_selector('.user-image.post-comment')
    end
  end
end