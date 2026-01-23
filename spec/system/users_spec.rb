# spec/system/users_spec.rb
require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
  end

  private

  def open_sign_up_modal
    # トップページに遷移する
    visit root_path

    # 初期状態ではモーダルが表示されていないことを確認する
    expect(page).to have_no_selector('.modal.sign-up', visible: true)

    # ページ内に「新規登録」の文字があることを確認する
    signup_target = find('.sign-up-btn-text', text: '新規登録', visible: :all)

    # 画面をスクロールさせる
    execute_script('arguments[0].scrollIntoView({block: "center"});', signup_target)
    # 0.5秒待機する
    sleep 0.5
    # hoverの代わりにモーダルを表示状態(block)にするJSを実行
    execute_script('document.querySelector(".modal.sign-up").style.display = "block";')
    # モーダルが表示されたことを確認する
    expect(page).to have_selector('.modal.sign-up', visible: true)
  end

  def access_sign_up_page
    # 新規登録用モーダルに｢メールアドレスでアカウント作成｣のボタンがあることを確認する
    expect(page).to have_content('メールアドレスでアカウント作成')
    # ボタンをクリックする
    click_link 'メールアドレスでアカウント作成'

    # 新規登録ページに遷移したことを確認する
    expect(page).to have_current_path(new_user_registration_path)
    expect(page).to have_content '新規登録フォーム'
  end

  context 'メールアドレスでユーザー新規登録ができる時' do 
    it '正しい情報を入力すれば新規登録ができ、トップページに移動する' do
      open_sign_up_modal
      access_sign_up_page

      # 必須事項を入力または選択する
      fill_in 'nickname',   with: @user.nickname
      fill_in 'birth_date', with: @user.birth_date.to_s
      select  '男性',        from: 'gender'
      fill_in 'email',      with: @user.email
      fill_in 'password',   with: @user.password
      fill_in 'password_confirmation', with: @user.password_confirmation

      # 任意項目である画像をアップロードできることを確認する
      image_path = Rails.root.join('spec/fixtures/Doflamingo.png')
      attach_file('user[image]', image_path)
      # プレビュー画像が表示されることを確認する
      expect(page).to have_selector('.upload-image-list img')

      # 削除ボタンが表示されていることを確認（画像の検証ツールに見えるボタン）
      expect(page).to have_selector('.image-delete-btn', text: '削除')
      # 画像を一度削除し、画像と削除ボタンが消えていることを確認する
      if has_link?('削除')
        click_link '削除'
        expect(page).to have_no_selector('.upload-image-list img')
        # 一度削除した画像を再度アップロードできることを確認する
        attach_file('user[image]', image_path)
      end

      # 登録ボタンを押すとユーザーモデルのカウントが1上がることを確認する
      expect{
        find('input[name="commit"]').click
      }.to change { User.count }.by(1)

      # トップページへ遷移したことを確認する
      expect(page).to have_current_path(root_path)
      # トップページに「新規登録」テキストが表示されていないことを確認する
      # expect(page).to have_no_content('新規登録') 未実装
      # トップページにユーザー名が表示されていることを確認する
      # expect(page).to have_content(@user.nickname) 未実装
    end
  end

  context 'メールアドレスでユーザー新規登録ができない時' do
    it '必須項目が空欄だったり、誤った情報では登録できず、新規登録ページに遷移する' do
      open_sign_up_modal
      access_sign_up_page

      # 必須項目を空欄にする
      fill_in 'nickname',      with: ''
      fill_in 'birth_date',      with: ''
      select  '--',             from: 'gender'
      fill_in 'email',      with: ''
      fill_in 'password',   with: ''
      fill_in 'password_confirmation', with: ''
      # 「登録する」ボタンを押してもユーザーモデルのカウントが増えないことを確認する
      expect{
        find('input[name="commit"]').click
      }.to change { User.count }.by(0)
      # 新規登録ページへ戻されることを確認する
      expect(page).to have_current_path("/users")
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content 'ニックネームを入力してください'
    end
  end

  context 'SNSでユーザー新規登録ができる時' do
    it 'Google連携後に必要な情報を入力すれば登録でき、トップページに移動する' do
      # テスト専用のGoogleモックを作成する
      @user = FactoryBot.build(:user)
      
      # SNSモックの設定する
      auth_hash = OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456',
        info: { nickname: @user.nickname, email: @user.email }
      })
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
      
      open_sign_up_modal

      # 新規登録用モーダルに｢Google｣の文字とボタンがあることを確認する
      expect(page).to have_content('Google')
      # ボタンをクリックする
      click_link 'Google'

      # 認証が終わり、新規登録画面（/users/auth/google_oauth2/callback）に遷移していることを確認
      expect(page).to have_current_path("/users/auth/google_oauth2/callback")
      expect(page).to have_content '新規登録フォーム'

      # ニックネームとメールアドレスのフォームが入力済みであることを確認する
      expect(find('#nickname').value).to eq(@user.nickname)
      expect(find('#email').value).to eq(@user.email)

      # パスワードとパスワード(確認用)のフォームがないことを確認する
      expect(page).to have_no_selector('#password')
      expect(page).to have_no_selector('#password_confirmation')
      # 残りの必須項目を入力する
      fill_in 'birth_date', with: '1990-01-01'
      select '男性', from: 'gender'
      # 登録ボタンを押すとフラッシュメッセージが表示されること、ユーザーモデルのカウントが1上がることを確認する
      expect {
        find('input[name="commit"]').click
        expect(page).to have_content('登録が完了しました'), wait: 10
      }.to change { User.count }.by(1)

      # トップページへ遷移したことを確認する
      expect(page).to have_current_path(root_path)
      # トップページに「新規登録」テキストが表示されていないことを確認する
      # expect(page).to have_no_content('新規登録') 未実装
      # トップページにユーザー名が表示されていることを確認する
      # expect(page).to have_content(@user.nickname) 未実装
    end
  end
end