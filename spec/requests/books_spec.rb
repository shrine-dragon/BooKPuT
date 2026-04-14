require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:user)       { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let!(:book)       { FactoryBot.create(:book, user: other_user) }

  describe '投稿機能' do
    before { sign_in user }

    context '有効なパラメータの場合' do
      it '投稿が成功し、BookとContentが増えること' do
        content_params = [ FactoryBot.attributes_for(:book_content) ] # 配列にするのが一般的

        book_params = FactoryBot.attributes_for(:book).merge(
          category_id: 1,
          book_contents_attributes: content_params
        )

        expect do
          post books_path, params: { book: book_params }
        end.to change(Book, :count).by(1)
          .and change(BookContent, :count).by(1)

        expect(response).to redirect_to(root_path)
      end
    end

    context '無効なパラメータの場合' do
      it '投稿が失敗し、レコードが増えないこと' do
        expect do
          post books_path, params: { book: { title: '' } }
        end.not_to change(Book, :count)
      end
    end
  end

  describe '権限チェック' do
    context 'ログインしていない場合' do
      it '新規投稿ページにアクセスするとトップページにリダイレクトされる' do
        get new_book_path
        expect(response).to redirect_to(root_path)
      end
    end

    context '自分以外の他人の投稿を操作する場合' do
      before {sign_in user }

      it '他人の投稿編集ページにアクセスするとトップページにリダイレクトされる' do
        get edit_book_path(book)
        expect(response).to redirect_to(root_path)
      end

      it '他人の投稿を削除しようとするとトップページにリダイレクトされること' do
        expect {
          delete book_path(book)
        }.not_to change(Book, :count)
    
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
