require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    @comment = FactoryBot.build(:comment)
    sleep 0.1
  end

  describe 'コメント投稿機能' do
    context 'コメントを投稿できる時' do
      it '文字が入力されていれば投稿できる' do
        expect(@comment).to be_valid
      end
    end

    context 'コメントを投稿できない時' do
      it '文字が入力されていないと投稿できない' do
        @comment.text = ''
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Textを入力してください')
      end

      it '文字が100文字を超える(101文字以上)と投稿できない' do
        @comment.text = 'a' * 101
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Textを100文字以内で入力してください')
      end

      it 'userが紐づいていないと投稿できない' do
        @comment.user = nil
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Userを入力してください')
      end

      it 'bookが紐づいていないと投稿できない' do
        @comment.book = nil
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Bookを入力してください')
      end
    end
  end
end
