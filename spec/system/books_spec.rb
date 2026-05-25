require 'rails_helper'

RSpec.describe '新規投稿', type: :system do
  let(:user)         { FactoryBot.create(:user) }
  let(:book)         { FactoryBot.build(:book) }
  let(:book_content) { FactoryBot.build(:book_content) }
  
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

      latest_book = Book.last
      target_card = find('.book-card')
      scroll_to(target_card, align: :center)

      # カードにカーソルを合わせる（ホバー状態にする）
      target_card.hover

      # 隠れている要素が表示されることを確認する
      expect(page).to have_selector('.hover-details', wait: 5)

      # 投稿した画像とタイトル、カテゴリーとジャンルが表示されていることを確認する
      expect(page).to have_selector('.book-posted-image', wait: 10)
      expect(page).to have_content(latest_book.title)
      expect(page).to have_content(latest_book.category.name)
      book.genres.each do |genre|
        expect(page).to have_content(genre.name)
      end

      first_content = latest_book.book_contents.first.content

      # 内容項目の内、「最初の1文字」が含まれていることを確認する
      expect(page).to have_content(first_content[0])

      # 内容項目は2行までしか表示されないことを確認する
      if latest_book.book_contents.count > 2
        expect(target_card).to have_selector('.content-list li', count: 3)
        expect(target_card).to have_content('…')
      else
        expect(target_card).to have_selector('.content-list li', count: latest_book.book_contents.count)
      end
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
      end.not_to change(Book, :count)

      # エラーメッセージのリストを定義する
      error_messages = %w[
        タイトルを入力してください
        本の種類を選択してください
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

    it '未ログインユーザーは新規投稿できない' do
      not_log_in_user

      # ｢投稿する｣ボタンを押してもログインモーダルが表示され、新規投稿ページに遷移できないことを確認する
      scroll_display('.right-bottom-btn')

      expect(page).to have_content('ログインが必要です', wait: 10)
      expect(page).to have_selector('.modal.log-in', visible: true)

      # URLでは｢http://localhost:3000/books/new｣となっている
      expect(page).to have_current_path(new_book_path)

      not_log_in_user_access_denied(new_book_path, '新規投稿')
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
      book = FactoryBot.build(:book, category_id: 1)
      visit_new_book_path

      # 項目を入力・選択し、ジャンルは最大3つまで選択する
      fill_in_new_post_form

      # チェックされている数が3つであることを確認する
      expect(page).to have_selector('input[type="checkbox"]:checked', count: 3)
      # チェックが入っていない残りのジャンルがすべて「無効化(disabled)」されているかを確認する
      uncheck_boxes = all('input.genre-checkbox:not(:checked)')
      uncheck_boxes.each do |cb|
        expect(cb).to be_disabled
      end

      # 投稿ボタンを押し、ジャンルが3つ保存されていることを確認する
      expect do
        click_on '投稿する'
        expect(page).to have_content('投稿しました')
      end.to change { Book.count }.by(1)
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

    it '本のジャンルで一度でも｢回答しない｣にチェックを入れると、他のジャンルが選択できなくなる' do
      visit_new_book_path
      scroll_to(find('#category'), align: :center)

      # ｢--｣｢その他｣｢回答しない｣を除く全カテゴリー全パターンを網羅する
      Category.where(id: 1..9).each do |category|
        select category.name, from: 'category'
        expect(page).to have_selector('.genre-option', visible: true)
        check '回答しない'
        all('.genre-option').each do |option|
          # そのオプションの中にある input と label を探す
          checkbox = option.find('input[type="checkbox"]', visible: :all)
          label_text = option.text

          if label_text == '回答しない'
            expect(checkbox).not_to be_disabled
          else
            expect(checkbox).to be_disabled
          end
        end

        # チェックを外すと、再び全て選択可能（disabled解除）になることを確認する
        uncheck '回答しない'
        expect(page).to have_no_selector('#genre-section input:disabled')
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
        find('#add-content-btn').click if i > 0

        fill_in "book_content_#{i}", with: "#{i + 1}つ目の内容項目です"
        expect(page).to have_content("(残り#{6 - i}項目)") if i < 6
      end
      expect(all('.input-main-part').count).to eq 7

      # ｢投稿する｣ボタンを押すとBookContentモデルのカウントが7上がることを確認する
      expect do
        click_on '投稿する'
        expect(page).to have_content('投稿しました')
      end.to change { BookContent.count }.by(7)
    end
  end
end

RSpec.describe '投稿詳細', type: :system do
  let(:user1)        { FactoryBot.create(:user) }
  let(:user2)        { FactoryBot.create(:user) }
  let(:user3)        { FactoryBot.create(:user) }
  let!(:book)        { FactoryBot.create(:book, user: user1) }
  let(:book_content) { book.book_contents.first }

  context '投稿詳細を閲覧できる時' do
    it '全ユーザーは投稿詳細ページで投稿内容をチェックできる' do
      [user1, user2, user3, nil].each do |one_user|
        if one_user
          login_as one_user
        else
          # 未ログイン状態を作るためのヘルパー（Wardenのログアウト処理、または独自メソッド）
          logout if respond_to?(:logout) 
        end

        visit_book_path

        # 投稿詳細ページに投稿したユーザーの情報と投稿内容の各項目が表示されていることを確認する
        expect(page).to have_selector('.user-image.posted-by')
        expect(page).to have_content(user1.nickname)

        expect(page).to have_content(book.title)
        # src属性にActiveStorageのファイル名が含まれているかを確認する
        expect(find('.book-posted-image')[:src]).to include('Momose-Akira-no-firstLove-failing')

        expect(page).to have_content("# #{book.category.name}")

        book.genres.each do |genre|
          expect(page).to have_content("# #{genre.name}")
        end

        book.book_contents.each do |content|
          expect(page).to have_content(content.content)
        end
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

RSpec.describe '投稿編集', type: :system do
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let!(:book) { FactoryBot.create(:book, user: user1) }
  let(:user)  { user1 }

  context '投稿を編集できる時' do
    it 'ログインユーザーは自身の投稿を編集できる' do
      # user1でログインする
      login_as user1

      visit_book_path

      # 編集ボタンを押し、投稿編集ページに遷移する
      expect(page).to have_selector('#post-edit-btn', text: '編集', wait: 5)
      click_on('編集')
      expect(page).to have_current_path(edit_book_path(book))
      expect(page).to have_content('投稿編集')

      # すでに保存済みのアカウント情報がフォームに入っていることを確認する
      expect(
        find('#title').value
      ).to eq(book.title)

      expect(
        find('#category').value
      ).to eq(book.category_id.to_s)

      book.genres.each do |genre|
        expect(
          # ラベルのテキストから対応するチェックボックスを探し、それがチェックされているか確認する
          page.has_checked_field?(genre.name)
        ).to be_truthy
      end

      book.book_contents.each_with_index do |content, i|
        expect(
          find("#book_content_#{i}").value
        ).to eq(content.content)
      end

      # 保存済みの画像がプレビューで表示されていることを確認する
      expect(page).to have_selector('.upload-image-list img')

      # 編集内容を定義する
      new_title = 'anotherTitle'
      new_category_name = '雑誌'
      new_genres = %w[漫画 アニメ ファッション]

      # 各項目を編集する
      fill_in 'title', with: new_title
      select new_category_name, from: 'category'

      # 一旦すべてのチェックを外す（既存のチェックがあるため）
      all('#genre-section input[type="checkbox"]').each do |checkbox|
        uncheck checkbox[:id] if checkbox.checked?
      end

      new_genres.each { |genre_name| check genre_name }

      (0..6).each do |i|
        # ループの中で「その番号用のテキスト」を作り、即座に fill_in する
        new_content = "編集後の#{i + 1}つ目の内容項目です"
        fill_in "book_content_#{i}", with: new_content
      end

      # 既存の画像を削除し、新しい画像を添付する
      image_path = Rails.root.join('spec/fixtures/Momose_Akira_no_firstlove_failing_2.png')
      attach_file('book[image]', image_path)
      # 新しい画像のプレビューが表示されることを確認する
      expect(page).to have_selector('.upload-image-list img')

      # 編集ボタンを押し、詳細ページに遷移していることを確認する
      click_on('更新する')
      expect(page).to have_content('更新しました', wait: 5)
      expect(page).to have_current_path(book_path(book))

      # 詳細ページで内容が更新されていることを確認する
      expect(page).to have_content(new_title)
      expect(page).to have_content(new_category_name)
      new_genres.each do |genre_name|
        expect(page).to have_content(genre_name)
      end
      (0..6).each do |i|
        expect(page).to have_content("編集後の#{i + 1}つ目の内容項目です")
      end

      expect(page).to have_selector('.book-posted-image')
    end
  end

  context '投稿を編集できない時' do
    it '未ログインユーザーは自身の投稿を編集できない' do
      not_log_in_user
      visit_book_path

      # 投稿詳細ページに編集ボタンが存在しないことを確認する
      expect(page).to have_no_selector('#post-edit-btn', wait: 5)

      not_log_in_user_access_denied(edit_book_path(book), '投稿編集')
    end

    it 'ログインユーザーであっても他人の投稿を編集できない' do
      # user2でログインする
      login_as user2
      # user1が作成した投稿の詳細ページに遷移する
      visit_book_path

      # 投稿詳細ページに編集ボタンが存在しないことを確認する
      expect(page).to have_no_selector('#post-edit-btn', wait: 5)

      # URLで編集ページへ移動しようとするとトップページに遷移することを確認する
      log_in_user_access_denied(edit_book_path(book), '投稿編集')
    end
  end
end

RSpec.describe '投稿削除', type: :system do
  let(:user1)  { FactoryBot.create(:user) }
  let(:user2)  { FactoryBot.create(:user) }
  let!(:book)  { FactoryBot.create(:book, user: user1) }
  let(:user)   { user1 }

  context '投稿を削除できる時' do
    it 'ログインユーザーは自身の投稿を削除できる' do
      login_as user1
      visit_book_path

      # 最初の削除ボタンを押し、投稿削除用のモーダルを開く
      expect(page).to have_selector('#destroy-post-btn', text: '削除', wait: 5)
      find('#destroy-post-btn').click
      expect(page).to have_selector('.modal.final-action.destroy-post', visible: true, wait: 5)
      expect(page).to have_content('この投稿を削除しますか？')

      # ｢本当に削除する｣ボタンを押すと、BookモデルとBookContentモデルのカウントが1下がることを確認する
      expect do
        find('.final-action.btn-text').click
        expect(page).to have_content('投稿を削除しました')
      end.to change { Book.count }.by(-1)
                                  .and change { BookContent.count }.by(-7)

      # トップページに遷移し、投稿が削除されていることを確認する
      expect(page).to have_current_path(root_path)
      expect(page).to have_no_selector('.book-posted-image')
      expect(page).to have_no_content(book.title)
    end
  end

  context '投稿を削除できない時' do
    it '未ログインユーザーは自身の投稿を削除できない' do
      # ログインせずにトップページに遷移する
      not_log_in_user
      visit_book_path

      # 投稿詳細ページに削除ボタンが存在しないことを確認する
      expect(page).to have_no_selector('#destroy-post-btn', wait: 5)
    end

    it 'ログインユーザーであっても他者の投稿を削除できない' do
      # user2でログインする
      login_as user2
      # user1が作成した投稿の詳細ページに遷移する
      visit_book_path

      # 投稿詳細ページに削除ボタンが存在しないことを確認する
      expect(page).to have_no_selector('#destroy-post-btn', wait: 5)
    end

    it '自身の投稿であっても｢削除しない｣ボタンや閉じるボタン、投稿削除用モーダル以外の要素を押すと削除できない' do
      login_as user1
      visit_book_path

      # 最初の削除ボタンを押し、投稿削除用のモーダルを開く
      expect(page).to have_selector('#destroy-post-btn', text: '削除', wait: 5)

      selectors = ['.no-action.btn-text', '.fa-xmark', '#modal-overlay']

      selectors.each do |_selector|
        find('#destroy-post-btn').click
        expect(page).to have_selector('.modal.final-action.destroy-post', visible: true, wait: 5)
        expect do
          if _selector == '#modal-overlay'
            page.execute_script("document.querySelector('#modal-overlay').click();")
          else
            find(_selector).click
          end
          expect(page).to have_no_selector('.modal.final-action.destroy-post', wait: 5)
        end.not_to(change { Book.count })
      end
    end
  end
end
