require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe '新規登録機能' do
    context '新規登録できる時' do
      it '必須項目が全て正しく入力・選択されていれば登録できる' do
        expect(@user).to be_valid
      end

      it '画像が未選択でも登録できる' do
        @user.image = nil
        expect(@user).to be_valid
      end
    end

    context '新規登録できない時' do
      it 'ニックネームが未入力だと登録できない' do
        @user.nickname = ''
        @user.valid?
        expect(@user.errors.full_messages).to include('ニックネームを入力してください')
      end

      it 'ニックネームが16文字を超える(17文字以上)と登録できない' do
        @user.nickname = 'a' * 17
        @user.valid?
        expect(@user.errors.full_messages).to include('ニックネームを16文字以内で入力してください')
      end

      it '生年月日が未入力だと登録できない' do
        @user.birth_date = ''
        @user.valid?
        expect(@user.errors.full_messages).to include('生年月日を入力してください')
      end

      it '生年月日が今日より後の日付（未来）だと登録できない' do
        @user.birth_date = Date.today + 1.day
        @user.valid?
        expect(@user.errors.full_messages).to include('生年月日は今日以前の日付を選択してください')
      end

      it '性別が選択されていないと登録できない' do
        @user.gender_id = 0
        @user.valid?
        expect(@user.errors.full_messages).to include('性別を選択してください')
      end

      it 'メールアドレスが未入力だと登録できない' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include('メールアドレスを入力してください')
      end

      it 'メールアドレスに@が含んでいないと登録できない' do
        @user.email = 'aaaaaa.com'
        @user.valid?
        expect(@user.errors.full_messages).to include('メールアドレスは不正な形式です')
      end

      it 'メールアドレスに@以降のドメイン表記が誤っていると登録できない' do
        @user.email = 'aaaaaa.@gmeil.coma'
        @user.valid?
        expect(@user.errors.full_messages).to include('メールアドレスは不正な形式です')
        expect(@user.errors.full_messages).to include('メールアドレスのドメイン(@以降)が正しくありません（例: gmail.com）')
      end

      it '同じメールアドレスは登録できない' do
        @user.save
        another_user = FactoryBot.build(:user, email: @user.email)
        another_user.valid?
        expect(another_user.errors.full_messages).to include('メールアドレスはすでに使用されています')
      end

      it 'パスワードが未入力だと登録できない' do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードを入力してください')
      end

      it 'パスワードが8文字未満(7文字以下)だと登録できない' do
        @user.password = 'abCD123'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードを8文字以上で入力してください')
      end

      it 'パスワードが20文字を超える(21文字以上)と登録できない' do
        @user.password = 'abcdeFGHIJ12345678910'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードを20文字以内で入力してください')
      end

      it 'パスワードが全角だと登録できず、半角英数混合でないといけない' do
        @user.password = 'aaaaああああ1234ａａａａ'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードが半角であっても、英大文字のみでは登録できない' do
        @user.password = 'ABCDEFGHIJ'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードが半角であっても、英子文字のみでは登録できない' do
        @user.password = 'abcdefghij'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードが半角であっても、数字のみでは登録できない' do
        @user.password = '12345678910'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードが半角であっても、英大文字と英子文字のみでは登録できない' do
        @user.password = 'ABCDEfghij'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードが半角であっても、英大文字と数字のみでは登録できない' do
        @user.password = 'ABCDE12345'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードが半角であっても、英子文字と数字のみでは登録できない' do
        @user.password = 'abcde12345'
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字の大文字・小文字・数字をすべて含めて入力してください')
      end

      it 'パスワードとパスワード(確認用)が一致していないと登録できない' do
        @user.password = 'abcDE12345'
        @user.password_confirmation = 'abcDEF123456'
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワード(確認用)とパスワードが一致しません')
      end
    end
  end
end
