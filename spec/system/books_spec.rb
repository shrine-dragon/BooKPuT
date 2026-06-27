require 'rails_helper'

RSpec.describe '投稿機能', type: :system do
  let(:user)         { FactoryBot.create(:user) }
  let(:user1)        { FactoryBot.create(:user) }
  let(:user2)        { FactoryBot.create(:user) }
  let(:user3)        { FactoryBot.create(:user) }

  describe '新規投稿' do
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

        # book投稿の画像・タイトル・カテゴリー名・ジャンル名・投稿者の画像がそれぞれ表示されていることを確認する
        expect(page).to have_selector('.book-posted-image', wait: 10)
        expect(page).to have_content(latest_book.title)
        expect(page).to have_content(latest_book.category.name)
        book.genres.each do |genre|
          expect(page).to have_content(genre.name)
        end
        expect(page).to have_selector('.card-badge.book-poster')

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

        # マイページのマイ投稿内に投稿内容が存在していることを確認する
        visit user_path(user)
        scroll_to(find('.my-page-contents.books-list'), align: :center)

        sleep 0.5

        expect(page).to have_content('マイ投稿：1件')
        expect(page).to have_selector('.book-posted-image')
        expect(page).to have_content(book.title)
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
        FactoryBot.build(:book, category_id: 1)
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

  describe '投稿詳細' do
    let!(:book)        { FactoryBot.create(:book, user: user1) }
    let(:book_content) { book.book_contents.first }

    context '投稿詳細を閲覧できる時' do
      it '全ユーザーは投稿詳細ページで投稿内容をチェックできる' do
        [user1, user2, user3, nil].each do |one_user|
          if one_user
            login_as one_user
          elsif respond_to?(:logout)
            # 未ログイン状態を作るためのヘルパー（Wardenのログアウト処理、または独自メソッド）
            logout
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

  describe '投稿編集' do
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

  describe '投稿削除' do
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

        # マイページに遷移し、投稿が存在しないことを確認する
        visit user_path(user)
        scroll_to(find('.my-page-contents.books-list'), align: :center)

        sleep 0.5

        expect(page).to have_content('マイ投稿：0件')
        expect(page).to have_content('投稿はありません')
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

  describe '投稿通報' do
    let!(:book)  { FactoryBot.create(:book, user: user1) }
    let(:user)   { user1 }

    context '投稿を通報できる時' do
      it 'book投稿者以外のログインユーザーは、他者の投稿を通報できる' do
        login_as user2
        visit_book_path

        # 最初の通報ボタンを押し、投稿通報用のモーダルを開く
        expect(page).to have_selector('#report-post-btn', text: '通報', wait: 5)

        find('#report-post-btn').click
        expect(page).to have_selector('.modal.final-action.report-post', visible: true, wait: 5)
        expect(page).to have_content('この投稿を不適切な内容として通報しますか？')

        # ｢通報する｣ボタンを押すと、ReportedBookモデルのカウントが1上がることを確認する
        expect do
          find('.modal.final-action.report-post .final-action.btn-text').click
          expect(page).to have_content('投稿を通報しました')
        end.to change { ReportedBook.count }.by(1)

        # 💡 JSによるHTML属性（data-reported="true"）の書き換えが完了するまで一瞬だけ待つ、またはアサーションで同期を取る
        expect(page).to have_selector('#report-post-btn[data-reported="true"]', wait: 5)

        # 再度通報ボタンを押すと｢通報済みの投稿です｣と表示され、ReportedBookモデルのカウントは変わらないことを確認する
        expect do
          find('#report-post-btn').click
          sleep 0.5
          expect(page).to have_content('通報済みの投稿です')
          expect(page).to have_no_selector('.modal.final-action.report-post', visible: true, wait: 5)
        end.to change { ReportedBook.count }.by(0)
      end
    end

    context '投稿を通報できない時' do
      it '未ログインユーザーは投稿自体を通報できない' do
        not_log_in_user
        visit_book_path

        # 投稿詳細ページに｢通報｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('#report-post-btn', text: '通報')
      end

      it 'book投稿者本人は自身の投稿を通報できない' do
        login_as user1
        visit_book_path

        # 投稿詳細ページにuser1のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)

        # 投稿詳細ページに｢通報｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('#report-post-btn', text: '通報')
      end

      it 'book投稿者以外のログインユーザーでも｢通報する｣ボタン以外の要素を押すとモーダルは閉じてしまい、投稿を通報できない｣' do
        [user2, user3].each do |one_user|
          login_as one_user
          visit_book_path
          expect(page).to have_content(one_user.nickname)

          close_modal_final_action('report-post', '通報')
        end
      end
    end
  end

  describe '投稿高評価' do
    let!(:book)     { FactoryBot.create(:book, user: user1) }
    let(:user)      { user1 }

    context '投稿を高評価できる時' do
      it 'book投稿者以外のログインユーザーは投稿を高評価できる' do
        login_as user2
        visit_book_path

        # 投稿詳細ページに高評価ボタンが存在していることを確認する
        expect(page).to have_selector('.fa-regular.fa-thumbs-up.hovers.posted-book', visible: true)

        # 高評価ボタンを押すと、BookGoodモデルのカウントが1上がることを確認する
        expect do
          find('.fa-regular.fa-thumbs-up.hovers.posted-book').click
          sleep 0.5
        end.to change { BookGood.count }.by(1)

        # 高評価済みであることと、高評価数が｢1｣と表示されていることを確認する
        expect(page).to have_selector('.fa-solid.fa-thumbs-up.hovers.posted-book')
        expect(page).to have_selector('.book-good-count', text: '1', wait: 5)

        # マイページの高評価リストに高評価した投稿が追加されていることを確認する
        visit user_path(user2)

        scroll_to(find('.my-page-contents.good-books-list'), align: :center)

        sleep 0.5

        expect(page).to have_content('高評価リスト：1件')
        expect(page).to have_selector('.book-posted-image')
        expect(page).to have_content(book.title)
      end
    end

    context '投稿を高評価できない時' do
      it '未ログインユーザーは投稿の高評価自体ができない' do
        not_log_in_user
        visit_book_path

        cannot_click_valuation_btn('up', 'book', BookGood)
      end

      it 'book投稿者本人は自身の投稿を高評価できない' do
        login_as user1
        visit_book_path

        # 投稿詳細ページにuser1（book投稿者本人）のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)

        cannot_click_valuation_btn('up', 'book', BookGood)
      end

      it '一度投稿を高評価しても、低評価ボタンを押すとコメントの高評価は取り消されてしまう' do
        FactoryBot.create(:book_good, user: user2, book: book)

        login_as user2
        visit_book_path

        sleep 0.5

        # 投稿詳細ページにuser1（book投稿者本人）のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)

        # 高評価済みであることと、高評価数が｢1｣と表示されていることを確認する
        expect(page).to have_selector('.fa-solid.fa-thumbs-up.hovers.posted-book')
        expect(page).to have_selector('.book-good-count', text: '1', wait: 5)

        expect(page).to have_selector('.fa-regular.fa-thumbs-down.hovers.posted-book', visible: true)

        # 低評価ボタンを押すと、BookGoodモデルのカウントが1下がることを確認する
        expect do
          find('.fa-regular.fa-thumbs-down.hovers.posted-book').click
          sleep 0.5
        end.to change { BookGood.count }.by(-1)

        # 高評価が取り消され、高評価数が非表示になっていることを確認する
        expect(page).to have_no_selector('.fa-solid.fa-thumbs-up.hovers.posted-book')
        expect(page).to have_no_selector('.book-good-count')
      end
    end
  end

  describe '投稿低評価' do
    let!(:book)     { FactoryBot.create(:book, user: user1) }
    let(:user)      { user1 }

    context '投稿を低評価できる時' do
      it 'book投稿者以外のログインユーザーは投稿を低評価できる' do
        login_as user2
        visit_book_path

        # 投稿詳細ページに低評価ボタンが存在していることを確認する
        expect(page).to have_selector('.fa-regular.fa-thumbs-down.hovers.posted-book', visible: true)

        # 低評価ボタンを押すと、BookBadモデルのカウントが1上がることを確認する
        expect do
          find('.fa-regular.fa-thumbs-down.hovers.posted-book').click
          sleep 0.5
        end.to change { BookBad.count }.by(1)

        # 低評価済みであることを確認する
        expect(page).to have_selector('.fa-solid.fa-thumbs-down.hovers.posted-book')
      end
    end

    context '投稿を低評価できない時' do
      it '未ログインユーザーは投稿の低評価自体ができない' do
        not_log_in_user
        visit_book_path

        cannot_click_valuation_btn('down', 'book', BookBad)
      end

      it 'book投稿者本人は自身の投稿を低評価できない' do
        login_as user1
        visit_book_path

        # 投稿詳細ページにuser1（book投稿者本人）のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)
        cannot_click_valuation_btn('down', 'book', BookBad)
      end

      it '一度投稿を低評価しても、高評価ボタンを押すと投稿の低評価は取り消されてしまう' do
        FactoryBot.create(:book_bad, user: user2, book: book)

        login_as user2
        visit_book_path

        sleep 0.5

        # 投稿詳細ページにuser1（book投稿者本人）のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)

        # 低評価済みであることとを確認する
        expect(page).to have_selector('.fa-solid.fa-thumbs-down.hovers.posted-book')

        expect(page).to have_selector('.fa-regular.fa-thumbs-up.hovers.posted-book', visible: true)

        # 高評価ボタンを押すと、BookBadモデルのカウントが1下がることを確認する
        expect do
          find('.fa-regular.fa-thumbs-up.hovers.posted-book').click
          sleep 0.5
        end.to change { BookBad.count }.by(-1)

        # 低評価が取り消されていることを確認する
        expect(page).to have_no_selector('.fa-solid.fa-thumbs-down.hovers.posted-book')
      end
    end
  end

  describe '投稿お気に入り追加' do
    let!(:book)     { FactoryBot.create(:book, user: user1) }
    let(:user)      { user1 }

    context '投稿をお気に入りに追加できる時' do
      it 'book投稿者以外のログインユーザーは他者の投稿をお気に入りに追加できる' do
        login_as user2
        visit_book_path

        # 投稿詳細ページにお気に入りボタンが存在していることを確認する
        expect(page).to have_selector('.fa-regular.fa-star.hovers', visible: true)

        # お気に入りボタンを押すと、Favoriteモデルのカウントが1上がることを確認する
        expect do
          find('.fa-regular.fa-star.hovers').click
          sleep 0.5
        end.to change { Favorite.count }.by(1)

        # お気に入りに追加済みであることを確認する
        expect(page).to have_selector('.fa-solid.fa-star.hovers')

        # マイページのお気に入りリストに投稿が追加されていることを確認する
        visit user_path(user2)
        scroll_to(find('.my-page-contents.favorite-books-list'), align: :center)

        sleep 0.5

        expect(page).to have_content('お気に入りリスト：1件')
        expect(page).to have_selector('.book-posted-image')
        expect(page).to have_content(book.title)
      end
    end

    context '投稿をお気に入りに追加できない時' do
      it '未ログインユーザーは投稿のお気に入り追加自体ができない' do
        not_log_in_user
        visit_book_path

        # 投稿詳細ページにお気に入りボタン自体が存在していないことを確認する
        expect(page).to have_no_selector('.fa-regular.fa-star.hovers')
      end

      it 'book投稿者本人は自身の投稿をお気に入りに追加できない' do
        login_as user1
        visit_book_path

        # 投稿詳細ページにuser1（book投稿者本人）のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)

        expect(page).to have_no_selector('.fa-regular.fa-star.hovers')
      end

      it '一度投稿をお気に入りに追加しても、再度お気に入りボタンを押すと取り消されてしまう' do
        FactoryBot.create(:favorite, user: user2, book: book)

        login_as user2
        visit_book_path

        sleep 0.5

        # 投稿詳細ページにuser1（book投稿者本人）のニックネームが表示されていることを確認する
        expect(page).to have_content(user1.nickname)

        # お気に入りに追加済みであることを確認する
        expect(page).to have_selector('.fa-solid.fa-star.hovers')

        # 再度お気に入りボタンを押すと、Favoriteモデルのカウントが1下がることを確認する
        expect do
          find('.fa-solid.fa-star.hovers').click
          sleep 0.5
        end.to change { Favorite.count }.by(-1)

        # お気に入り追加が取り消されていることを確認する
        expect(page).to have_no_selector('fa-solid.fa-star.hovers')
        sleep 0.5
        expect(page).to have_selector('.fa-regular.fa-star.hovers', visible: true)

        # マイページのお気に入りリストに投稿が削除されていることを確認する
        visit user_path(user2)
        scroll_to(find('.my-page-contents.favorite-books-list'), align: :center)

        sleep 0.5

        expect(page).to have_content('お気に入りリスト：0件')
        expect(page).to have_content('お気に入りに追加した投稿はありません')
        expect(page).to have_no_selector('.book-posted-image')
        expect(page).to have_no_content(book.title)
      end
    end
  end

  describe "投稿検索", type: :system do
    let!(:book) { FactoryBot.create(:book, user: user1) }
    let(:book2) { FactoryBot.create(:book, user: user1) }
    let(:book3) { FactoryBot.create(:book, user: user1) }

    before do
      visit root_path
    end

    context '投稿検索ができる時' do
      it 'キーワードをbook投稿のタイトル・カテゴリー名・ジャンル名・内容項目、そしてユーザー名のいずれかで検索した場合' do
        find_search_form
        # 検索ワードを配列にする
        matched_keywords = [
          book.title, 
          book.category.name, 
          book.genres.first.name, 
          book.book_contents.first.content, 
          book.user.nickname
        ]
        # 検索ワードでそれぞれ検索し、同じbook投稿がヒットすることを確認する
        matched_keywords.each do |matched_keyword|
          fill_in 'keyword', with: matched_keyword
          visit_search_books_path

          show_search_result
        end
      end

      it 'キーワードを空にして検索した場合' do
        find_search_form
        # キーワードを空にして検索する
        keyword = ''
        fill_in 'keyword', with: keyword
        visit_search_books_path
        # 検索結果に全ての投稿がヒットすることを確認する
        show_search_result
      end

      it 'キーワードをbook投稿のタイトル・カテゴリー名・ジャンル名、そしてユーザー名のいずれとも一致しないものにして検索した場合' do
        find_search_form
        # キーワードを適当な文字にして検索する
        keyword = 'あab1い234cうえ56defお78かgきhiく9けこ0j'
        fill_in 'keyword', with: keyword
        visit_search_books_path

        sleep 0.5
        # 検索結果が0件を表すテキストが表示されていることを確認する
        expect(page).to have_content(keyword && '「」' && 'に一致する投稿は見つかりませんでした。')
        expect(page).to have_no_content("検索結果")

        expect(page).to have_no_content(book.title)
        expect(page).to have_no_selector(".book-posted-image")
      end
    end
  end
end
