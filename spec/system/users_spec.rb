# frozen_string_literal: true

# spec/system/users_spec.rb
require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
  end

  context 'メールアドレスでユーザー新規登録ができる時' do
    it '正しい情報を入力すれば新規登録ができ、トップページに移動する' do
      open_modal(:'sign-up', '新規登録')
      access_sign_up_page

      # 必須事項を入力または選択する
      fill_in 'nickname',   with: @user.nickname
      fill_in 'birth_date', with: @user.birth_date.to_s
      select  '男性', from: 'gender'
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

      submit_and_expect_success('.cyan-submit-btn', 1, '登録が完了しました')
    end
  end

  context 'メールアドレスでユーザー新規登録ができない時' do
    it '必須項目が空欄だったり、誤った情報では登録できず、新規登録ページに遷移する' do
      open_modal(:'sign-up', '新規登録')
      access_sign_up_page

      # 必須項目を空欄にする
      fill_in 'nickname', with: ''
      fill_in 'birth_date', with: ''
      select  '--', from: 'gender'
      fill_in 'email',      with: ''
      fill_in 'password',   with: ''
      fill_in 'password_confirmation', with: ''
      # 「登録する」ボタンを押してもユーザーモデルのカウントが増えないことを確認する
      expect  do
        scroll_display('.cyan-submit-btn')
      end.to change { User.count }.by(0)
      # 新規登録ページへ戻されることを確認する
      expect(page).to have_current_path('/users')
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content 'ニックネームを入力してください'
    end
  end

  ['Google', 'X(Twitter)', 'Facebook', 'LINE'].each do |sns|
    it "#{sns}連携後に必要な情報を入力すれば登録でき、トップページに移動する" do
      # 1. プロバイダー名をシンボルに変換（google_oauth2, twitter, facebook, line）
      provider = case sns
                 when 'Google'     then :google_oauth2
                 when 'X(Twitter)' then :twitter
                 else sns.downcase.to_sym
                 end

      # 2. 以前の it ブロックに書いていた共通処理
      OmniAuth.config.mock_auth[provider] = nil
      @user = FactoryBot.build(:user, password: nil, password_confirmation: nil)

      auth_hash = OmniAuth::AuthHash.new({
                                           provider: provider.to_s,
                                           uid: SecureRandom.uuid,
                                           info: { nickname: @user.nickname, email: @user.email }
                                         })
      OmniAuth.config.mock_auth[provider] = auth_hash

      open_modal(:'sign-up', '新規登録')
      click_link sns

      input_info_and_sign_up(provider.to_s)
      submit_and_expect_success('.cyan-submit-btn', 1, '登録が完了しました')
    end

    it "#{sns}連携をキャンセルすると新規登録モーダルがあるトップページに戻る" do
      provider = case sns
                 when 'Google'     then :google_oauth2
                 when 'X(Twitter)' then :twitter
                 else sns.downcase.to_sym
                 end

      # 認証の失敗をシミュレート
      OmniAuth.config.mock_auth[provider] = :invalid_credentials

      open_modal(:'sign-up', '新規登録')
      click_link sns

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'メールアドレスでログインができる時' do
    it '正しい情報を入力すればログインでき、トップページに移動する' do
      open_modal('log-in', 'ログイン')
      # 必須事項を入力する
      fill_in 'email',      with: @user.email
      fill_in 'password',   with: @user.password

      submit_and_expect_success('.log-in-submit-btn', 0, 'ログインしました')
    end
  end

  context 'メールアドレスでログインができない時' do
    it '必須項目が空欄のままボタンを押してもログインできない' do
      open_modal('log-in', 'ログイン')
      # 必須事項を空欄にする
      fill_in 'email',      with: ''
      fill_in 'password',   with: ''
      click_btn_and_no_change
    end

    it '入力情報が登録情報と異なる状態でボタンを押してもログインできず、エラーメッセージが表示される' do
      open_modal('log-in', 'ログイン')
      # 異なる情報を入力する
      fill_in 'email',    with: "wrong_#{@user.email}"
      fill_in 'password', with: 'wrong_password'
      click_btn_and_no_change
      expect(page).to have_content('メールアドレスまたはパスワードが違います。')
    end
  end

  sns_login_data = {
    'Google' => { provider: :google_oauth2, selector: '#google-log-in', message: 'Google アカウントでログインしました。' },
    'X(Twitter)' => { provider: :twitter, selector: '#twitter-log-in', message: 'X アカウントでログインしました。' },
    'Facebook' => { provider: :facebook, selector: '#facebook-log-in', message: 'Facebook アカウントでログインしました。' },
    'LINE' => { provider: :line, selector: '#line-log-in', message: 'LINE アカウントでログインしました。' }
  }

  context 'SNSでログインができる時' do
    sns_login_data.each do |sns_name, data| # eachで引数（名前とデータの中身）を受け取る
      it "#{sns_name}認証が成功すればログインでき、トップページに遷移する" do
        create_log_in_mock_data(data[:provider]) # 引数としてハッシュの値を渡す
        open_modal('log-in', 'ログイン')

        submit_and_expect_success(data[:selector], 0, data[:message])
      end
    end
  end

  context 'SNSでログインができない時' do
    sns_login_data.each do |sns_name, data|
      it "#{sns_name}認証をキャンセルするとログインできず、トップページに戻る" do
        OmniAuth.config.mock_auth[data[:provider]] = :invalid_credentials

        open_modal('log-in', 'ログイン')
        scroll_display(data[:selector])

        return_to_top_page_and_show_flash_message('認証に失敗しました')
      end
    end
  end
end

RSpec.describe 'ログアウト', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'ログアウトができる時' do
    it 'ログインユーザーはモーダルからログアウトでき、トップページの表示が変わる' do
      # 最初からログイン状態にし、トップページに遷移する
      login_as(@user)
      visit root_path

      # 初期状態ではモーダルが表示されていないことを確認する
      expect(page).to have_no_selector('.modal.log-in-user', visible: true)

      # ページ内にログインユーザーのニックネームが表示されていることを確認する
      login_user_target = find('.user-nickname', text: @user.nickname, visible: :all)

      # 画面をスクロールさせる
      execute_script('arguments[0].scrollIntoView({block: "center"});', login_user_target)
      # 0.5秒待機する
      sleep 0.5
      # menuの代わりにモーダルを表示状態(block)にするJSを実行
      execute_script('document.querySelector(".modal.log-in-user").style.display = "block";')
      # モーダルが表示されたことを確認する
      expect(page).to have_selector('.modal.log-in-user', visible: true)

      # ｢ログアウト｣ボタンをクリックし、トップページにフラッシュメッセージが表示されていることを確認する
      click_on('ログアウト')
      return_to_top_page_and_show_flash_message('ログアウトしました')

      # トップページにユーザーのニックネームが表示されていないことを確認する
      expect(page).to have_no_content(@user.nickname)
    end
  end

  context 'ログアウトができない時' do
    it '未ログインユーザーはログアウトできず、トップページの表示も変わらない' do
      # トップページに｢ログイン｣｢新規登録｣の文字があり、未ログインの状態であることを確認する
      visit root_path
      expect(page).to have_content('ログイン')
      expect(page).to have_content('新規登録')
      # トップページにユーザーのニックネームが表示されていないことを確認する
      expect(page).to have_no_content(@user.nickname)
    end
  end
end

RSpec.describe 'パスワード変更', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'パスワードの変更ができる時' do
    it '未ログインの状態でパスワード再設定ページへ遷移し、正しい情報を入力すればパスワードを変更できる' do
      open_modal('log-in', 'ログイン')
      scroll_display('.forget-password')

      # パスワード再設定ページに遷移していることを確認する
      expect(page).to have_current_path('/users/password/new', wait: 5)
      # フィールドが出るまで最大5秒待つ
      expect(page).to have_field('email', wait: 5)

      # 登録済みのメールアドレスを入力する
      fill_in 'email', with: @user.email
      # 入力されたメールアドレスが正しいか、送信前にチェックを入れる
      expect(page).to have_field('email', with: @user.email)
      click_on('送信する')

      # メール送信完了ページに遷移していることを確認する
      expect(page).to have_current_path('/passwords/email_submitted')

      get_token_and_access_edit_password_page

      # フィールドが出るまで最大5秒待つ
      expect(page).to have_field('password', wait: 5)
      expect(page).to have_field('password_confirmation', wait: 5)

      # 新しいパスワードを入力する
      new_pw = 'NewPassword1234'

      fill_in 'password', with: new_pw
      fill_in 'password_confirmation', with: new_pw

      # 入力されたパスワードが正しいか、送信前にチェックを入れる
      expect(page).to have_field('password', with: new_pw)
      expect(page).to have_field('password_confirmation', with: new_pw)

      # パスワードを変更する
      click_on '変更する'

      # パスワード変更完了ページに遷移していることを確認する
      expect(page).to have_current_path('/passwords/updated')
      expect(page).to have_content('パスワードの変更が完了しました。')

      # トップページへ戻り、ログインできている（＝ニックネームがある）ことを確認する
      click_on 'トップページへ戻る'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(@user.nickname)
    end
  end

  context 'パスワードの変更ができない時' do
    it 'ログインユーザーはログインモーダル経由でパスワード再設定ページへ遷移して、パスワードを変更できない' do
      login_as(@user)
      visit root_path
      # トップページにユーザーのニックネームが存在し、ログイン状態であることを確認する
      expect(page).to have_content(@user.nickname)
      # トップページに｢ログイン｣の文字がないことを確認する
      expect(page).to have_no_content('ログイン')
    end

    it 'メールアドレスを空欄にするとエラーメッセージが表示され、パスワードを変更できない' do
      # パスワード再設定のためのメールアドレス入力ページへ遷移する
      visit new_user_password_path

      # メールアドレスを空欄にして｢送信する｣ボタンを押す
      fill_in 'email', with: ''
      click_on('送信する')
      # メール送信完了ページへ遷移せず、エラーメッセージが表示されていることを確認する
      expect(page).to have_current_path('/users/password', wait: 10)
      expect(page).to have_selector('.error-message', text: 'メールアドレスを入力してください')
    end

    it '未登録のメールアドレスを入力するとパスワード再設定用のメールは届かず、パスワードも変更できない' do
      # パスワード再設定のためのメールアドレス入力ページへ遷移する
      visit new_user_password_path

      # 未登録のメールアドレスを入力にして｢送信する｣ボタンを押すが、パスワード再設定用のメールが届いていないことを確認する
      fill_in 'email', with: 'non-registered@example.com'
      expect do
        click_on('送信する')
      end.to change { ActionMailer::Base.deliveries.size }.by(0)

      # メール送信完了ページへ遷移する
      expect(page).to have_current_path(email_submitted_path)
    end

    it '無効な入力内容（例：パスワード不一致）ではエラーメッセージが表示され、パスワードを変更できない' do
      get_token_and_access_edit_password_page

      # フィールドが出るまで最大5秒待つ
      expect(page).to have_field('password', wait: 5)
      expect(page).to have_field('password_confirmation', wait: 5)

      # パスワードと確認用パスワードをわざと違うものにする
      new_pw = 'NewPassword1234'
      fill_in 'password', with: new_pw
      fill_in 'password_confirmation', with: "#{new_pw}5"

      # 入力されたパスワードが正しいか、送信前にチェックを入れる
      expect(page).to have_field('password', with: new_pw)
      expect(page).to have_field('password_confirmation', with: "#{new_pw}5")

      # ｢変更する｣ボタンを押す
      click_on '変更する'

      # パスワード変更完了ページへ遷移せず、エラーメッセージが表示されていることを確認する
      expect(page).to have_current_path('/users/password', wait: 10)
      expect(page).to have_selector('.error-message', text: 'パスワード（確認用）とパスワードが一致しません')
    end
  end
end
