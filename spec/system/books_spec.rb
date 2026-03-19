require 'rails_helper'

RSpec.describe '新規投稿', type: :system do
  include UserSupport
  include BookSupport

  before do
    @user = FactoryBot.create(:user)
    @book = FactoryBot.build(:book)
  end

  context '新規投稿ができる時' do
    it '正しい情報を入力すれば新規投稿ができ、トップページに移動する' do
      # ログインし、トップページに遷移する
      login_as(@user)
      visit root_path
      # トップページに｢投稿する｣ボタンがあることを確認する

      # ｢投稿する｣ボタンを押すと、新規投稿ページに遷移することを確認する

      # 必須項目を入力または選択する

      # 任意項目である画像をアップロードできることを確認する

      # プレビュー画像が表示されることを確認する

      # 画像を一度削除し、画像と削除ボタンが消えていることを確認する

      # 一度削除した画像を再度アップロードできることを確認する
    end
  end

  context '新規投稿ができない時' do
    it '必須項目が空欄だったり誤った情報ではエラーメッセージが表示され、投稿できない' do
      
    end

    it '未ログインユーザーは新規投稿できず、新規投稿ボタンを押すとログインモーダルが表示される' do
      
    end
  end
end