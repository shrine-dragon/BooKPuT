require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
    sleep 0.1
  end
  
  describe 'メールアドレスによる新規登録' do
    context 'ユーザー情報を保存できて新規登録できる時' do
      it '必須項目が全て正しく入力されていれば保存できる' do
        expect(@user).to be_valid
      end

      it '画像が選択されていなくても保存できる' do
        @user.image = nil
        expect(@user).to be_valid
      end
    end
  end
end
