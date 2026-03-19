require 'rails_helper'

RSpec.describe '新規投稿', type: :system do
  include UserSupport
  include BookSupport
  include OtherSupport

  before do
    @user = FactoryBot.create(:user)
    @book = FactoryBot.build(:book)
    @book_content = FactoryBot.build(:book_content)
  end

  context '新規投稿ができる時' do
    it '正しい情報を入力すれば新規投稿ができ、トップページに移動する' do
      # ログインし、トップページに遷移する
      login_as(@user)
      visit root_path
      # トップページに｢投稿する｣ボタンがあることを確認する
      expect(page).to have_selector('.right-bottom-btn-text.post', text: '投稿する', visible: false)
      # ｢投稿する｣ボタンを押すと、新規投稿ページに遷移することを確認する
      click_on('投稿する')
      expect(page).to have_current_path(new_book_path)

      # 必須項目を入力または選択する
      fill_in 'title',   with: @book.title
      select '漫画',      from: 'category'
      fill_in 'content', with: @book_content.content

      image_test('book[image]')

      # ｢投稿する｣ボタンを押すとBookモデルとBookContentモデルのカウントが1上がることを確認する
      expect do
        scroll_display('.orange-submit-btn')
      end.to change { Book.count }.by(1).and change { BookContent.count }.by(1)

      # トップページに遷移し、フラッシュメッセージが表示されていることを確認する
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('投稿しました')

      # トップページに投稿した画像とタイトルが表示されていることを確認する
      expect(page).to have_selector("img[src$='Doflamingo.png']")
      expect(page).to have_content(@book.title)
      # 投稿にカーソルを当てるとカテゴリー名と内容が表示されることを確認する
      post_element = find('.card-content-wrapper')
      post_element.hover

      expect(page).to have_content('漫画', wait: 5)
      expect(page).to have_content(@book_content.content)
    end
  end

  context '新規投稿ができない時' do
    it '必須項目が空欄だったり誤った情報ではエラーメッセージが表示され、投稿できない' do
      # ログインし、新規投稿ページに遷移する
      login_as(@user)
      visit new_book_path

      # 必須項目を空欄にする
      fill_in 'title',   with: ''
      select '--',      from: 'category'
      fill_in 'content', with: ''
      
      # ｢投稿する｣ボタンを押してもBookモデルとBookContentモデルのカウントが上がらないことを確認する
      expect do
        scroll_display('.orange-submit-btn')
      end.to change { Book.count }.by(0).and change { BookContent.count }.by(0)

      # 新規投稿ページで各入力項目にエラーメッセージが表示されていることを確認する
      expect(page).to have_current_path(books_path)
      expect(page).to have_content('タイトルを入力してください')
      .and have_content('本の種類を選択してください')
      .and have_content('内容項目を入力してください')
    end

    it '未ログインユーザーは新規投稿できず、新規投稿ボタンを押すとログインモーダルが表示される' do
      not_log_in_user

      # ｢投稿する｣ボタンを押してもログインモーダルが表示され、新規投稿ページに遷移できないことを確認する
      scroll_display('.right-bottom-btn')

      # URLでは｢http://localhost:3000/books/new｣となっている
      expect(page).to have_current_path(new_book_path)

      expect(page).to have_content('ログインが必要です', wait: 10)
      expect(page).to have_selector('.modal.log-in', visible: true)
    end
  end
end