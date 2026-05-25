require 'rails_helper'

RSpec.describe Book, type: :model do
  before do
    @book = FactoryBot.build(:book)
    sleep 0.1
  end

  describe '新規投稿機能' do
    context '投稿内容を保存できる時' do
      it '必須項目が全て正しく入力・選択されていれば保存できる' do
        expect(@book).to be_valid
      end

      it '画像が添付されていなくても保存できる' do
        @book.image = ''
        expect(@book).to be_valid
      end

      it '内容項目が7つ以内なら保存できる' do
        @book.book_contents.clear
        7.times { @book.book_contents.build(content: 'テスト') }
        expect(@book).to be_valid
      end
    end

    context '投稿内容を保存できない時' do
      it 'タイトルが入力されていないと保存できない' do
        @book.title = ''
        @book.valid?
        expect(@book.errors.full_messages).to include('タイトルを入力してください')
      end

      it 'タイトルが101文字以上だと保存できない' do
        @book.title = 'a' * 101
        @book.valid?
        expect(@book.errors.full_messages).to include('タイトルを100文字以内で入力してください')
      end

      it '本の種類が選択されていないと保存できない' do
        @book.category_id = 0
        @book.valid?
        expect(@book.errors.full_messages).to include('本の種類を選択してください')
      end

      it '本のジャンルが選択されていないと保存できない' do
        @book.genre_ids = []
        @book.valid?
        expect(@book.errors.full_messages).to include('本のジャンルを選択してください')
      end

      it 'ジャンルが4つ以上選択されていると保存できない' do
        @book.genre_ids = [1, 2, 3, 4]
        @book.valid?
        expect(@book.errors.full_messages).to include('本のジャンルは3つまで選択してください')
      end

      it '内容項目が入力されていないと保存できない' do
        @book.book_contents = []
        @book.valid?
        expect(@book.errors.full_messages).to include('内容項目を少なくとも1つ入力してください')
      end

      it '内容項目が51文字以上だと保存できない' do
        @book.book_contents.first.content = 'a' * 51
        @book.valid?
        expect(@book.errors.full_messages).to include('内容項目を50文字以内で入力してください')
      end

      it '内容項目が8項目以上だと保存できない' do
        7.times { @book.book_contents.build(content: 'テスト') }
        @book.valid?
        expect(@book.errors.full_messages).to include('内容項目を7項目以内で入力してください')
      end

      it 'userが紐づいていないと保存できない' do
        @book.user = nil
        @book.valid?
        expect(@book.errors.full_messages).to include('Userを入力してください')
      end
    end
  end
end
