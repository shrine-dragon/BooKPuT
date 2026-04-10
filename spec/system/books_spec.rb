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
      fill_in_new_post_form

      # ｢投稿する｣ボタンを押すとBookモデルとBookContentモデルのカウントが1上がることを確認する
      expect do
        scroll_display('.orange-submit-btn')
      end.to change { Book.count }.by(1)
        .and change { BookContent.count }.by(1)

      # トップページに遷移し、フラッシュメッセージが表示されていることを確認する
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('投稿しました')

      show_posted_contents
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

  context 'その他' do
    it '新規投稿ページに各サイトへの外部リンクが正しく設置されている' do
      visit_new_book_path

      expect(page).to have_link('Amazonから探す', href: /amazon\.co\.jp/)
      expect(page).to have_link('Googleから探す', href: /google\.com/)

      # 別タブで開く仕様であることを確認する
      expect(find_link('Amazonから探す')[:target]).to eq '_blank'
      expect(find_link('Googleから探す')[:target]).to eq '_blank'
    end

    it 'ジャンルは最大3つまで選択できる' do
      @book = FactoryBot.build(:book, category_id: 1)
      visit_new_book_path
      
      # 項目を入力・選択し、ジャンルは最大3つまで選択する
      fill_in_new_post_form
      
      # 4つ目が無効化されていることを確認する
      expect(find('label', text: 'バトル').find('input')).to be_disabled
      
      # 投稿ボタンを押し、ジャンルが3つ保存されていることを確認する
      expect {
        click_on '投稿する'
        expect(page).to have_content('投稿しました')
      }.to change { Book.count }.by(1)
      .and change { BookContent.count }.by(1)

      last_book = Book.last
      expect(last_book.genre_ids.length).to eq 3
    end

    it '本の種類で｢--｣｢その他｣｢回答しない｣を選択すると、ジャンル一覧が表示されない' do
      visit_new_book_path
      scroll_to(find('#category'), align: :center)

      ['--', 'その他', '回答しない'].each do |special_category|
        select special_category, from: 'category'
        expect(page).to have_no_selector('.genre-option')
      end

      # ｢--｣｢その他｣｢回答しない｣以外を選択するとジャンルは表示されることを確認する
      Category.where(id: 1..9).each do |category|
        select category.name, from: 'category'
        expect(page).to have_selector('.genre-option', visible: true)
      end
    end

    it '本のジャンルで｢その他｣｢回答しない｣にチェックを入れると、他のジャンルが選択できなくなる' do
      visit_new_book_path
      scroll_to(find('#category'), align: :center)

      # ｢--｣｢その他｣｢回答しない｣を除く全カテゴリー全パターンを網羅する
      Category.where(id: 1..9).each do |category|
        select category.name, from: 'category'
        expect(page).to have_selector('.genre-option', visible: true)
        ['その他', '回答しない'].each do |special_genre|
          check special_genre
          all('.genre-option').each do |option|
            # そのオプションの中にある input と label を探す
            checkbox = option.find('input[type="checkbox"]', visible: :all)
            label_text = option.text
            
            if label_text == special_genre
              expect(checkbox).not_to be_disabled
            else
              expect(checkbox).to be_disabled
            end
          end

          # チェックを外すと、再び全て選択可能（disabled解除）になることを確認する
          uncheck special_genre
          expect(page).to have_no_selector('#genre-section input:disabled')
        end
      end
    end

    it '内容項目の追加と削除が正常に動作し、内容項目は上最大7つまで入力・保存できる' do
      visit_new_book_path

      fill_in_new_post_form

      # 内容項目が最初は1つであることを確認する
      expect(all('.input-main-part').count).to eq 1

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

      # 内容項目を最大7つまで増やす
      (0..6).each do |i|
        if i > 0
          find('#add-content-btn').click
        end

        fill_in "book_content_#{i}", with: "#{i+1}つ目の内容項目です"
        expect(page).to have_content("(残り#{6-i}項目)") if i < 6
      end
      expect(all('.input-main-part').count).to eq 7

      # ｢投稿する｣ボタンを押すとBookContentモデルのカウントが7上がることを確認する
      expect {
        click_on '投稿する'
        expect(page).to have_content('投稿しました')
      }.to change { BookContent.count }.by(7)
    end
  end
end

RSpec.describe '投稿詳細', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @book = FactoryBot.create(:book, user: @user)
  end

  context '投稿詳細を閲覧できる時' do
    it '全ユーザーは投稿詳細ページで投稿内容をチェックできる' do
      # トップページに遷移し、投稿済みの内容をクリックする
      visit root_path
      find('.book-card-link').click
      # 投稿詳細ページに遷移したことを確認する
      expect(page).to have_current_path(book_path(@book))
      expect(page).to have_content('投稿詳細')

      #投稿詳細ページに投稿したユーザーの情報と投稿内容の各項目が表示されていることを確認する
      expect(page).to have_selector('.user-image.posted-by')
      expect(page).to have_content(@user.nickname)

      expect(page).to have_content(@book.title)
      # src属性にActiveStorageのファイル名が含まれているかを確認する
      expect(find('.book-posted-image')[:src]).to include('Momose-Akira-no-firstLove-failing')

      expect(page).to have_content("# #{@book.category.name}")

      @book.genres.each do |genre|
        expect(page).to have_content("# #{genre.name}")
      end
      
      @book.book_contents.each do |content|
        expect(page).to have_content(content.content)
      end
    end
  end

  context '投稿詳細を閲覧できない時' do
    it '投稿が1つもないと投稿詳細を閲覧できない' do
      # DBを一旦空にする
      Book.destroy_all
      # トップページで投稿が1つも存在しないことを確認する
      visit root_path
      expect(page).to have_content('投稿はありません')
      expect(page).to have_no_selector('.book-card-link')
    end
  end
end
