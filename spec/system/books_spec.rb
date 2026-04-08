require 'rails_helper'

RSpec.describe '新規投稿', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @book = FactoryBot.build(:book)
    @book_content = FactoryBot.build(:book_content)
  end

  context '新規投稿ができる時' do
    it '正しい情報を入力すれば新規投稿ができ、トップページに移動する' do
      visit_new_book_path

      # 必須項目を入力または選択する
      fill_in 'title', with: @book.title
      select '漫画', from: 'category'
      fill_in 'book_content_0', with: '1つ目の内容項目です'

      # 本の種類を選択すると本のジャンルが表示されることを確認する
      expect(page).to have_selector('#genre-section', visible: true)

      # 本のジャンルに最大3つまでチェックを入れる
      check '少年漫画'
      check '少女漫画'
      check '青年漫画'

      # 内容項目が最初は1つであることを確認する
      expect(all('.input-main-part').count).to eq 1

      # 内容項目を1つ追加し、2つ目の項目が増えたことを確認する
      find('#add-content-btn').click
      expect(all('.input-main-part').count).to eq 2
      expect(page).to have_selector('#book_content_1', wait: 5)

      # 2つ目の入力欄に値を入力する
      fill_in 'book_content_1', with: '2つ目の内容項目です'

      image_test('Momose-Akira-no-firstLove-failing.png', 'book[image]')

      # ｢投稿する｣ボタンを押すとBookモデルのカウントが1,BookContentモデルのカウントが2、Genreモデルのカウントが3上がることを確認する
      expect do
        scroll_display('.orange-submit-btn')
      end.to change { Book.count }.by(1)
                                  .and change { BookContent.count }.by(2)

      # トップページに遷移し、フラッシュメッセージが表示されていることを確認する
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('投稿しました')

      show_posted_contents
    end

    it '新規投稿ページに各サイトへの外部リンクが正しく設置されている' do
      visit_new_book_path

      expect(page).to have_link('Amazonから探す', href: /amazon\.co\.jp/)
      expect(page).to have_link('Googleから探す', href: /google\.com/)

      # 別タブで開く仕様であることを確認する
      expect(find_link('Amazonから探す')[:target]).to eq '_blank'
      expect(find_link('Googleから探す')[:target]).to eq '_blank'
    end

    it '内容項目の追加と削除が正常に動作する' do
      visit_new_book_path

      # 内容項目を1つ追加し、2つ目の項目が存在することを確認する
      find('#add-content-btn').click
      expect(page).to have_selector('#book_content_1')

      # 残りカウントが減少していることを確認する
      expect(page).to have_content('(残り5項目)')

      # 追加された内容項目の方の「−」ボタンをクリックする
      all('.remove-content-btn')[1].click

      # 2つ目の内容項目が削除され、カウントが戻ることを確認する
      expect(page).to have_no_selector('#book_content_1')
      expect(page).to have_content('(残り6項目)')
    end
  end

  context '新規投稿ができない時' do
    it '必須項目が空欄だったり誤った情報ではエラーメッセージが表示され、投稿できない' do
      visit_new_book_path

      # 必須項目を空欄にする
      fill_in 'title', with: ''
      select '--', from: 'category'
      fill_in 'book_content_0', with: ''

      # ｢投稿する｣ボタンを押してもBookモデルとBookContentモデルのカウントが上がらないことを確認する
      expect do
        scroll_display('.orange-submit-btn')
      end.to change { Book.count }.by(0)
                                  .and change { BookContent.count }.by(0)

      # エラーメッセージのリストを定義する
      error_messages = %w[
        タイトルを入力してください
        画像を選択し直してください
        本の種類を選択してください
        内容項目を入力してください
        内容項目を少なくとも1つ入力してください
      ]

      # 新規投稿ページで各入力項目にエラーメッセージが表示されていることを確認する
      expect(page).to have_current_path(books_path)

      error_messages.each do |message|
        expect(page).to have_content(message)
      end

      # 本の種類を選択した状態で投稿ボタンを押す
      select '漫画', from: 'category'
      expect do
        scroll_display('.orange-submit-btn')
      end

      # 新規投稿ページで本のジャンルにエラーメッセージが表示されていることを確認する
      expect(page).to have_current_path(books_path)
      expect(page).to have_content('本のジャンルを選択してください')
    end

    it 'ジャンルを上限の3つまで選択すると、他のジャンルが選択できない' do
      # 新規投稿ページで本の種類を選択する
      visit_new_book_path
      select '漫画', from: 'category'

      # 3つチェックを入れる
      check '少年漫画'
      check '少女漫画'
      check '青年漫画'

      # 4つ目のチェックボックスが disabled になっているか確認する
      # ※ 'バトル' はチェックしていない4つ目の項目と仮定
      expect(find('label', text: 'バトル').find('input')).to be_disabled
    end

    it '未ログインユーザーは新規投稿できず、新規投稿ボタンを押すとログインモーダルが表示される' do
      not_log_in_user

      # ｢投稿する｣ボタンを押してもログインモーダルが表示され、新規投稿ページに遷移できないことを確認する
      scroll_display('.right-bottom-btn')

      expect(page).to have_content('ログインが必要です', wait: 10)
      expect(page).to have_selector('.modal.log-in', visible: true)

      # URLでは｢http://localhost:3000/books/new｣となっている
      expect(page).to have_current_path(new_book_path)
    end
  end
end

RSpec.describe '投稿詳細', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @book = FactoryBot.build(:book)
    @book_content = FactoryBot.build(:book_content)
  end

  context '投稿詳細を閲覧できる時' do
    it '全ユーザーは投稿詳細ページで投稿内容をチェックできる' do
      new_post
      # トップページで投稿済みの内容をクリックする
      find('.book-card-link').click
      # 投稿詳細ページに遷移することを確認する
      expect(page).to have_current_path(book_path(Book.last))
      expect(page).to have_content('投稿詳細')

      #投稿詳細ページに投稿したユーザーの情報と投稿内容の各項目が表示されていることを確認する
      expect(page).to have_selector('.user-image.posted-by')
      expect(page).to have_content(@user.nickname)

      expect(page).to have_content(@book.title)
      expect(find('.book-posted-image')[:src]).to include('Momose-Akira-no-firstLove-failing')
      expect(page).to have_content('# 漫画', wait: 5)

      ['少年漫画', '少女漫画', '青年漫画'].each do |genre|
        expect(page).to have_content("# #{genre}")
      end
      
      (0..6).each do |i|
        expect(page).to have_content("#{i+1}つ目の内容項目です")
      end
    end
  end

  context '投稿詳細を閲覧できない時' do
    it '投稿が1つもないと投稿詳細を閲覧できない' do
      # トップページで投稿が1つも存在しないことを確認する
      visit root_path
      expect(page).to have_content('投稿はありません')
      expect(page).to have_no_selector('.book-card-link')
    end
  end
end
