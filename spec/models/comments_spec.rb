require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    @comment = FactoryBot.build(:comment)
    sleep 0.1
  end

  describe 'コメント投稿機能' do
    context '投稿内容を保存できる時' do
      it '文字が入力されていれば保存できる' do
        expect(@comment).to be_valid
      end
    end

    context '投稿内容を保存できない時' do
      it '文字が入力されていないと保存できない' do
        @comment.text = ''
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Textを入力してください')
      end

      it '文字が101文字以上だと保存できない' do
        @comment.text = 'a' * 101
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Textを100文字以内で入力してください')
      end

      it 'userが紐づいていないと保存できない' do
        @comment.user = nil
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Userを入力してください')
      end

      it 'bookが紐づいていないと保存できない' do
        @comment.book = nil
        @comment.valid?
        expect(@comment.errors.full_messages).to include('Bookを入力してください')
      end
    end
  end
end
