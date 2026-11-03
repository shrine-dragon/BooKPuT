require 'rails_helper'

RSpec.describe Contact, type: :model do
  before do
    @contact = FactoryBot.build(:contact)
  end

  describe 'お問い合わせ機能' do
    context 'お問い合わせ内容を送信できる時' do
      it '必須項目が全て正しく入力されていれば送信できる' do
        expect(@contact).to be_valid
      end

      it '件名が未入力でも送信できる' do
        @contact.subject = ''
        expect(@contact).to be_valid
      end
    end

    context 'お問い合わせ内容を送信できない時' do
      it '氏名が未入力だと送信できない' do
        @contact.name = ''
        @contact.valid?
        expect(@contact.errors.full_messages).to include('氏名を入力してください')
      end

      it 'メールアドレスが未入力だと送信できない' do
        @contact.email = ''
        @contact.valid?
        expect(@contact.errors.full_messages).to include('メールアドレスを入力してください')
      end

      it 'メールアドレスに@が含んでいないと登録できない' do
        @contact.email = 'aaaaaa.com'
        @contact.valid?
        expect(@contact.errors.full_messages).to include('メールアドレスは不正な形式です')
      end

      it 'メールアドレスに@以降のドメイン表記が誤っていると登録できない' do
        @contact.email = 'aaaaaa.@gmeil.coma'
        @contact.valid?
        expect(@contact.errors.full_messages).to include('メールアドレスは不正な形式です')
        expect(@contact.errors.full_messages).to include('メールアドレスのドメイン(@以降)が正しくありません（例: gmail.com）')
      end

      it 'メッセージ本文が未入力だと送信できない' do
        @contact.message = ''
        @contact.valid?
        expect(@contact.errors.full_messages).to include('メッセージ本文を入力してください')
      end

      it 'メッセージ本文が1000文字を超える(1001文字以上)と送信できない' do
        @contact.message = 'a' * 1001
        @contact.valid?
        expect(@contact.errors.full_messages).to include('メッセージ本文を1000文字以内で入力してください')
      end
    end
  end
end
