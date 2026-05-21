require 'rails_helper'

RSpec.describe 'コメント機能', type: :system do
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:user3) { FactoryBot.create(:user) }
  let!(:book) { FactoryBot.create(:book, user: user1) }
  
  let(:user)  { user1 }
  
  describe 'コメント投稿' do
    let(:comment) { FactoryBot.build(:comment, user: user2, book: book) }

    context 'コメントを投稿できる時' do
      it 'book投稿者以外のログインユーザーはコメント投稿ができる', js: true do
        login_as user2
        visit_book_path

        # コメントフォームが存在していることを確認する
        expect(page).to have_selector('.comment-form-text')
        # コメントフォームにテキストを入力する
        fill_in 'text', with: comment.text
        # コメント送信ボタンが表示されていることを確認する
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
      it '未ログインユーザーはコメント自体できない' do
        not_log_in_user
        visit_book_path

        # 投稿詳細ページにコメントフォームが存在していないことを確認する
        expect(page).to have_no_selector('.comment-form-text')
      end
      
      it 'book投稿者本人は自身の投稿に対してコメントできない' do
        login_as user1
        visit_book_path
        # 投稿詳細ページにコメントフォームなどが存在していないことを確認する
        expect(page).to have_no_selector('.comment-form-text')
        expect(page).to have_no_selector('.user-image.post-comment')
        expect(page).to have_no_selector('.user-image.post-comment')
      end

      it 'コメントフォームが空だと送信ボタンが表示されず、コメントできない' do
        login_as user2
        visit_book_path

        # コメントフォームが存在していることを確認する
        expect(page).to have_selector('.comment-form-text')
        # コメントフォームを空欄のままにする
        fill_in 'text', with: ''
        # コメント送信ボタンが表示されていないことを確認する
        expect(page).to have_no_selector('.submit-comment-btn', visible: true)
      end
    end
  end

  describe 'コメント編集' do
    let!(:comment) { FactoryBot.create(:comment, user: user2, book: book) }

    context 'コメントを編集できる時' do
      it 'コメント投稿者は自身のコメントを編集できる' do
        login_as user2
        visit_book_path
        check_comment_info

        # 投稿詳細ページに｢編集｣ボタンが表示されていることを確認する
        expect(page).to have_selector(".js-edit-comment-trigger", text: "編集")
        # ｢編集｣ボタンを押す
        find(".js-edit-comment-trigger", text: "編集").click

        within('.edit-comment-form') do
          # コメントフォームと、フォームの中にコメントテキストが表示されていることを確認する
          expect(page).to have_selector(".comment-form-text")
          expect(page).to have_field('comment[text]', with: comment.text)

          # 編集用のテキストを用意してフォームを更新する
          new_text = "anotherText"
          fill_in 'comment[text]', with: new_text

          # コメント更新ボタンが表示されていることを確認する
          expect(page).to have_selector('.edit-comment-btn', visible: true)

          # 更新ボタンを押すと投稿詳細ページに遷移して、フラッシュメッセージが表示されていることを確認する
          find('.edit-comment-btn').click
        end

        sleep 0.5
        expect(page).to have_content('コメントを更新しました', wait: 5)
        expect(page).to have_current_path(book_path(book))

        # 投稿詳細ページに編集したコメントが表示されていることを確認する
        expect(page).to have_content("anotherText")
      end
    end

    context 'コメントを編集できない時' do
      it '未ログインユーザーはコメント自体を編集できない' do
        not_log_in_user
        visit_book_path
        check_comment_info

        # コメントの下に｢編集｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('.js-edit-comment-trigger', text: '編集')
      end

      it 'コメント投稿者以外のログインユーザーは他者のコメントを削除できない' do
        [user1, user3].each do |user|
          login_as user
          visit_book_path
          check_comment_info
          expect(page).to have_no_selector('.js-edit-comment-trigger', text: '編集')
        end
      end

      it 'コメントフォームが空だと送信ボタンが表示されず、コメントを編集できない' do
        login_as user2
        visit_book_path
        check_comment_info

        expect(page).to have_selector(".js-edit-comment-trigger", text: "編集")
        find(".js-edit-comment-trigger", text: "編集").click

        within('.edit-comment-form') do
          expect(page).to have_selector(".comment-form-text")
          expect(page).to have_field('comment[text]', with: comment.text)

          # コメントフォームを空にする
          fill_in 'comment[text]', with: ''
          # コメント更新ボタンが表示されていないことを確認する
          expect(page).to have_no_selector('.edit-comment-btn', visible: true)
        end
      end

      it 'コメントフォームとコメント更新ボタン以外の部分を押すとフォームが閉じてしまい、コメントを編集できない' do
        login_as user2
        visit_book_path
        check_comment_info

        expect(page).to have_selector(".js-edit-comment-trigger", text: "編集")
        find(".js-edit-comment-trigger", text: "編集").click

        within('.edit-comment-form') do
          expect(page).to have_selector(".comment-form-text")
          expect(page).to have_field('comment[text]', with: comment.text)
        end

        # コメントフォームとコメント更新ボタン以外の部分を押すとフォームが消えてしまうことを確認する
        find('.detail-container').click
        expect(page).to have_no_selector(".edit-comment-form", wait: 5)

        # データベースのコメント件数が変わっていない（削除も更新もされていない）ことを確認する
        expect(comment.reload.text).to eq(comment.text)
      end
    end
  end

  describe 'コメント削除' do
    let!(:comment) { FactoryBot.create(:comment, user: user2, book: book) }

    context 'コメントを削除できる時' do
      it 'コメント投稿者は自身のコメントを削除できる', js: true do
        login_as user2
        visit_book_path
        check_comment_info

        final_action_of_comment_operation(
          "destroy-comment",
          "削除",
          "このコメントを削除しますか？",
          "削除する",
          Comment,
          -1,
          "コメントを削除しました",
          comment_index: :first
        )
        # 投稿詳細ページにコメントが存在せず、｢コメントはありません｣と表示されていることを確認する
        expect(page).to have_no_content(comment.text)
        expect(page).to have_content('コメントはありません')
      end
    end

    context 'コメントを削除できない時' do
      it '未ログインユーザーはコメント自体を削除できない' do
        not_log_in_user
        visit_book_path
        check_comment_info

        # コメントの下に｢削除｣ボタンが存在しないことを確認する
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

      it 'コメント投稿者本人でも｢削除する｣ボタン以外の要素を押すとモーダルは閉じてしまい、コメントを削除できない｣' do
        login_as user2
        visit_book_path
        check_comment_info

        close_modal_final_action("destroy-comment", "削除")
      end
    end
  end

  describe 'コメント非表示' do
    let!(:comment) { FactoryBot.create(:comment, user: user2, book: book) }

    context 'コメントを非表示にできる時' do
      it 'コメント投稿者以外のログインユーザーは、他者のコメントを非表示にできる' do
        login_as user1
        visit_book_path
        check_comment_info

        final_action_of_comment_operation(
          "hide-comment",
          "非表示",
          "このコメントを非表示にしますか？",
          "非表示にする",
          HiddenComment,
          1,
          "コメントを非表示にしました",
          comment_index: :first
        )

        # 投稿詳細ページでコメントが非表示になっていることを確認する
        expect(page).to have_no_content(comment.text)

        # 別のユーザーでログインした場合、投稿詳細ページでコメントは表示されていることを確認する
        login_as user3
        visit_book_path
        expect(page).to have_content(comment.text)
      end
    end

    context 'コメントを非表示にできない時' do
      it '未ログインユーザーはコメント自体を非表示にできない' do
        not_log_in_user
        visit_book_path
        check_comment_info

        # コメントの下に｢非表示｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('.js-hide-comment-trigger', text: '非表示')
      end

      it 'コメント投稿者本人は自身のコメントを非表示にできない' do
        login_as user2
        visit_book_path
        check_comment_info

        # コメント内にuser2のニックネームが表示されていることを確認する
        expect(page).to have_content(user2.nickname)

        # コメントの下に｢非表示｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('.js-hide-comment-trigger', text: '非表示')
      end

      it 'コメント投稿者以外のログインユーザーでも｢非表示にする｣ボタン以外の要素を押すとモーダルは閉じてしまい、コメントを非表示にできない｣' do
        [user1, user3].each do |one_user|
          login_as one_user
          visit_book_path
          check_comment_info

          close_modal_final_action("hide-comment", "非表示")
        end
      end
    end
  end

  describe 'コメント通報' do
    let!(:comment) { FactoryBot.create(:comment, user: user2, book: book) }

    context 'コメントを通報できる時' do
      it 'コメント投稿者以外のログインユーザーは、他者のコメントを通報できる' do
        login_as user1
        visit_book_path
        check_comment_info

        final_action_of_comment_operation(
          "report-comment",
          "通報",
          "このコメントを不適切な内容として通報しますか？",
          "通報する",
          ReportedComment,
          1,
          "コメントを通報しました",
          comment_index: :first
        )
        # 再度通報ボタンを押すと｢通報済みのコメントです｣と表示され、ReportedCommentモデルのカウントは変わらないことを確認する
        expect do
          find(".js-report-comment-trigger").click
          sleep 0.5
          expect(page).to have_content("通報済みのコメントです")
        end.to change { ReportedComment.count }.by(0)
      end
    end

    context 'コメントを通報できない時' do
      it '未ログインユーザーはコメント自体を通報できない' do
        not_log_in_user
        visit_book_path
        check_comment_info

        # コメントの下に｢通報｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('.js-report-comment-trigger', text: '通報')
      end

      it 'コメント投稿者本人は自身のコメントを通報できない' do
        login_as user2
        visit_book_path
        check_comment_info

        # コメント内にuser2のニックネームが表示されていることを確認する
        expect(page).to have_content(user2.nickname)

        # コメントの下に｢通報｣ボタンが存在しないことを確認する
        expect(page).to have_no_selector('.js-report-comment-trigger', text: '通報')
      end

      it 'コメント投稿者以外のログインユーザーでも｢通報する｣ボタン以外の要素を押すとモーダルは閉じてしまい、コメントを非表示にできない｣' do
        [user1, user3].each do |one_user|
          login_as one_user
          visit_book_path
          check_comment_info

          close_modal_final_action("report-comment", "通報")
        end
      end
    end
  end

  describe 'その他' do
    context 'コメントの一部表示・非表示機能' do
      it 'コメントが10件以下の場合、｢もっと見る｣ボタンが表示されない' do
        login_as user2
        visit_book_path

        # 最初はコメントが0件で｢コメントはありません｣と表示されていることを確認する
        expect(page).to have_selector('.empty-message.none-comment', text: 'コメントはありません')
        expect(page).to have_no_selector('.posted-comment-number')

        increase_comments(10)
      end

      it 'コメントが11件以上存在すると、｢もっと見る｣ボタンが表示される' do
        login_as user2
        visit_book_path

        increase_comments(11)
      end

      it 'コメントが11件存在している時、｢もっと見る｣ボタンを押すと｢折りたたむ｣ボタンが表示される' do
        login_as user2
        visit_book_path

        increase_comments(11)

        # ｢もっと見る｣ボタンを押す
        find('.view-more-comments-text').click

        # ｢折りたたむ｣ボタンが表示されていることを確認する
        expect(page).to have_selector('.hide-comments-text', text: '折りたたむ')
        # ｢折りたたむ｣ボタンを押すと表示中のコメントが10件に戻り、再度｢もっと見る｣ボタンが表示されることを確認する
        find('.hide-comments-text').click
        expect(page).to have_selector('.posted-comment-contents', count: 10)
        expect(page).to have_selector('.view-more-comments-text', text: 'コメントをもっと見る', visible: true)
      end

      it 'コメントが11件存在している状態でコメントを1件削除すると｢もっと見る｣ボタンは非表示になる' do
        login_as user2
        visit_book_path
    
        increase_comments(11)

        final_action_of_comment_operation(
          "destroy-comment",
          "削除",
          "このコメントを削除しますか？",
          "削除する",
          Comment,
          -1,
          "コメントを削除しました",
          comment_index: :first
        )

        expect(page).to have_no_selector('.view-more-comments-text', text: 'コメントをもっと見る')
      end

      it 'コメントが11件存在し、かつ｢折りたたむ｣ボタンが表示されている状態でコメントを1件削除すると、｢折りたたむ｣ボタンは非表示になる' do
        login_as user2
        visit_book_path

        increase_comments(11)

        # ｢もっと見る｣ボタンを押して｢折りたたむ｣ボタンを表示させる
        find('.view-more-comments-text').click
        expect(page).to have_selector('.hide-comments-text', text: '折りたたむ')

        final_action_of_comment_operation(
          "destroy-comment",
          "削除",
          "このコメントを削除しますか？",
          "削除する",
          Comment,
          -1,
          "コメントを削除しました",
          comment_index: :first
        )

        expect(page).to have_no_selector('.hide-comments-text', text: '折りたたむ')
      end

      it 'コメントが21件以上存在している状態で｢コメントをもっと見る｣ボタンを押すと、コメントは10件ずつ表示される' do
        login_as user2
        visit_book_path
        
        increase_comments(21)
      end
    end
  end
end