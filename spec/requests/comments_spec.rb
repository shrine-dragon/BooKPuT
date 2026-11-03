require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:user)   { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let!(:book) { FactoryBot.create(:book, user: other_user) }

  let!(:my_comment)    { FactoryBot.create(:comment, user: user, book: book) }
  let!(:other_comment) { FactoryBot.create(:comment, user: other_user, book: book) }

  describe 'コメント投稿機能' do
    context 'ログインしている場合' do
      before { sign_in user }

      it '有効なパラメータならコメントが保存され、status: 200 (Ajax成功) が返ること' do
        comment_params = FactoryBot.attributes_for(:comment)

        expect do
          post book_comments_path(book), params: { comment: comment_params }, xhr: true
        end.to change(Comment, :count).by(1)

        # 画面遷移（redirect_to）ではなく、JSが返るためstatusコードの200
        expect(response).to have_http_status(:ok)
      end
    end

    context 'ログインしていない場合' do
      it 'コメント投稿できず、ログイン画面（またはトップ）にリダイレクトされること' do
        expect do
          post book_comments_path(book), params: { comment: { text: 'テスト' } }
        end.not_to change(Comment, :count)

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'コメント削除機能' do
    context 'ログインしている場合' do
      before { sign_in user }

      it '自分のコメントは削除できること' do
        expect do
          delete book_comment_path(book, my_comment), xhr: true
        end.to change(Comment, :count)
        expect(response).to have_http_status(:ok)
      end

      it '他人のコメントは削除しようとしてもリダイレクト（または403）され、削除できないこと' do
        expect do
          delete book_comment_path(book, other_comment), xhr: true
        end.not_to change(Comment, :count)

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '非表示・通報機能' do
    context 'ログインしていない場合' do
      it '他人のコメントを通報しようとするとログイン画面にリダイレクトされること' do
        post report_book_comment_path(book, other_comment)
        expect(response).to redirect_to(root_path)
      end

      it '他人のコメントを非表示にしようとするとログイン画面にリダイレクトされること' do
        post hide_book_comment_path(book, other_comment)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'ログインしている場合' do
      before { sign_in user }

      it '他人のコメントを非表示にできること' do
        # HiddenCommentモデルなどのカウントが増えるか検証
        expect do
          post hide_book_comment_path(book, other_comment), xhr: true
        end.to change(HiddenComment, :count).by(1)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
