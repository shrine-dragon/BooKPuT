require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  describe '権限チェック' do
    context 'ログインしていない場合' do
      it '編集関連のページにアクセスするとトップページにリダイレクトされること' do
        edit_paths = [
          edit_profile_user_path(user),
          edit_email_user_path(user),
          edit_password_user_path(user)
        ]

        edit_paths.each do |path|
          get path
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context '自分以外のユーザーの編集画面にアクセスした場合' do
      it '編集関連のページにアクセスするとトップページにリダイレクトされること' do
        edit_paths = [
          edit_profile_user_path(other_user),
          edit_email_user_path(other_user),
          edit_password_user_path(other_user)
        ]

        edit_paths.each do |path|
          get path
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
