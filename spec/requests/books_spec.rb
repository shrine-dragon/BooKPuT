require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe 'POST /books' do
    before { sign_in user }

    context '有効なパラメータの場合' do
      it '投稿が成功し、リダイレクトされること' do
        content_params = {
          '0' => FactoryBot.attributes_for(:book_content)
        }

        book_params = FactoryBot.attributes_for(:book).merge(
          category_id: 1,
          book_contents_attributes: content_params
        )

        expect do
          post books_path, params: { book: book_params }
        end.to change(Book, :count).by(1)

        expect do
          post books_path, params: { book: book_params }
        end.to change(BookContent, :count).by(1)

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
end
