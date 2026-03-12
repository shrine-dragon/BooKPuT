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

      # 解約ボタンが表示されていることを確認（画像の検証ツールに見えるボタン）
      expect(page).to have_selector('.delete-image-btn', text: '削除')
      # 画像を一度削除し、画像と削除ボタンが消えていることを確認する
      if has_link?('削除')
        click_link '削除'
        expect(page).to have_no_selector('.upload-image-list img')
        # 一度削除した画像を再度アップロードできることを確認する
        attach_file('user[image]', image_path)
      end

      submit_and_expect_success('.orange-submit-btn', 1, '登録が完了しました')
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
        scroll_display('.orange-submit-btn')
      end.to change(User, :count).by(0)
      # 新規登録ページへ戻されることを確認する
      expect(page).to have_current_path(user_registration_path)
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
      submit_and_expect_success('.orange-submit-btn', 1, '登録が完了しました')
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
      expect(page).to have_content('メールアドレスまたはパスワードが違います')
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
      log_in_and_show_modal

      # ｢ログアウト｣ボタンをクリックし、トップページにフラッシュメッセージが表示されていることを確認する
      click_on('ログアウト')
      return_to_top_page_and_show_flash_message('ログアウトしました')

      # トップページにユーザーのニックネームが表示されていないことを確認する
      expect(page).to have_no_content(@user.nickname)
    end
  end

  context 'ログアウトができない時' do
    it '未ログインユーザーはログアウトできず、トップページの表示も変わらない' do
      not_log_in_user
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
      expect(page).to have_current_path(new_user_password_path, wait: 5)
      # フィールドが出るまで最大5秒待つ
      expect(page).to have_field('email', wait: 5)

      # 登録済みのメールアドレスを入力する
      fill_in 'email', with: @user.email
      # 入力されたメールアドレスが正しいか、送信前にチェックを入れる
      expect(page).to have_field('email', with: @user.email)
      click_on('送信する')

      # メール送信完了ページに遷移していることを確認する
      expect(page).to have_current_path(email_submitted_path)

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

      # 変更するボタンを押す
      click_on '変更する'

      # パスワード変更完了ページに遷移していることを確認する
      expect(page).to have_current_path(update_completion_path)
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
      expect(page).to have_current_path(user_password_path, wait: 10)
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
      expect(page).to have_current_path(user_password_path, wait: 10)
      expect(page).to have_selector('.error-message', text: 'パスワード（確認用）とパスワードが一致しません')
    end
  end
end

RSpec.describe 'マイページ', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'マイページへ遷移できる時' do
    it 'ログインユーザーはモーダルからマイページへ遷移し、アカウント情報やログイン情報を閲覧できる' do
      log_in_and_show_modal

      # ｢マイページ｣ボタンをクリックし、マイページへ遷移していることを確認する
      click_on('マイページ')
      expect(page).to have_current_path(user_path(@user), wait: 15)
      # マイページにアカウント情報やログイン情報が表示されていることを確認する
      expect(page).to have_content(@user.nickname)
      expect(page).to have_content(@user.birth_date.strftime('%Y/%m/%d'))
      expect(page).to have_content(@user.gender.name)
      expect(page).to have_content(@user.masked_email)
      expect(page).to have_content('********')
    end
  end

  context 'マイページへ遷移ができない時' do
    it '未ログインユーザーはマイページへ遷移して、アカウント情報やログイン情報を閲覧できない' do
      not_log_in_user

      another_user = FactoryBot.create(:user)
      not_log_in_user_access_denied(user_path(another_user))
    end

    it 'ログインユーザーであっても別のユーザーのマイページへ遷移し、アカウント情報やログイン情報を閲覧できない' do
      # 別ユーザーのアカウントを作成する
      another_user = FactoryBot.create(:user)
      log_in_user_access_denied(user_path(another_user))
    end
  end

  context 'プロフィールを編集できる時' do
    it '必須事項を全て入力していれば編集できる' do
      log_in_and_visit_my_page
      click_btn_and_check_account_info

      # 編集内容を定義する
      new_nickname = 'anotherNickname'
      new_birth_date = Date.new(1995, 1, 1)
      new_gender_name = '女性'

      # プロフィールを編集する
      fill_in 'nickname', with: new_nickname
      fill_in 'birth_date', with: new_birth_date
      select new_gender_name, from: 'gender'

      # 更新ボタンを押すとマイページへ遷移し、フラッシュメッセージが表示されることを確認する
      click_btn_and_visit_my_page_and_show_flash_message('更新する')

      # マイページには変更した内容が反映されていることを確認する
      expect(page).to have_content(new_nickname)
      expect(page).to have_content(new_birth_date.strftime('%Y/%m/%d'))
      expect(page).to have_content(new_gender_name)
    end

    it '新規登録時に未設定だった画像をプロフィール編集で追加できる' do
      log_in_and_visit_my_page
      # 最初はデフォルト画像が表示されていることを確認（imgタグのsrc属性などで判定）
      expect(page).to have_selector('#no-image')
      # 編集ボタンを押すとプロフィール編集ページへ遷移することを確認する
      click_on('プロフィールを編集する')
      expect(page).to have_current_path(edit_profile_user_path(@user))

      # 画像を添付する
      image_path = Rails.root.join('spec/fixtures/Doflamingo.png')
      attach_file('user[image]', image_path)
      # プレビューが表示されることを確認する
      expect(page).to have_selector('.upload-image-list img')

      click_btn_and_visit_my_page_and_show_flash_message('更新する')

      # デフォルト画像が消え、新しくアップロードした画像が表示されていることを確認
      expect(page).to have_no_selector('#no-image')
      expect(page).to have_selector('.current-user-image')
    end

    it '設定済みのプロフィール画像を削除してデフォルトに戻すことができる' do
      # あらかじめ画像を持たせた状態でテストを開始する
      image_path = Rails.root.join('spec/fixtures/Doflamingo.png')
      @user.image.attach(io: File.open(image_path), filename: 'Doflamingo.png')

      log_in_and_visit_my_page

      # 最初は設定した画像が表示されていることを確認する
      expect(page).to have_selector('.current-user-image')
      expect(page).to have_no_selector('#no-image')

      # 編集ボタンを押すとプロフィール編集ページへ遷移することを確認する
      click_on('プロフィールを編集する')
      expect(page).to have_current_path(edit_profile_user_path(@user))

      # 削除ボタンを押すとプレビューが消えることを確認する
      find('.delete-image-btn', text: '削除').click
      expect(page).to have_no_selector('.upload-image-list img')

      click_btn_and_visit_my_page_and_show_flash_message('更新する')

      # ユーザー画像がデフォルト（no-image）になっていることを確認する
      expect(page).to have_selector('#no-image')
    end
  end

  context 'プロフィールを編集できない時' do
    it '必須項目を空欄にするとエラーメッセージが表示され、編集できない' do
      log_in_and_visit_my_page
      click_btn_and_check_account_info
      # 必須項目を全て空欄にする
      fill_in 'nickname', with: ''
      fill_in 'birth_date', with: ''
      select '--', from: 'gender'
      # 更新ボタンを押す
      click_on('更新する')
      # エラーメッセージが表示され、編集ページに戻されることを確認する
      expect(page).to have_current_path(user_path(@user))
      expect(page).to have_content('ニックネームを入力してください')
      expect(page).to have_content('ニックネームを3文字以上で入力してください')
      expect(page).to have_content('生年月日を入力してください')
      expect(page).to have_content('性別を選択してください')

      # 編集画面の項目（例：ニックネームラベル）がまだ存在することを確認する
      expect(page).to have_content('ニックネーム(必須)')
    end
  end

  context 'メールアドレスを変更できる時' do
    it '@を含んだメールアドレスを入力していれば変更できる' do
      log_in_and_visit_my_page
      click_btn_and_check_email

      # 別のメールアドレスを入力し、変更ボタンを押す
      fill_in 'email', with: 'anotherEmail@example.com'
      click_btn_and_visit_my_page_and_show_flash_message('変更する')

      # 変更したメールアドレス(伏せ字つき)が表示されていることを確認する
      expect(page).to have_content('a********@example.com')
    end
  end

  context 'メールアドレスを変更できない時' do
    it 'メールアドレスが空欄だとエラーメッセージが表示され、変更できない' do
      log_in_and_visit_my_page
      click_btn_and_check_email

      # メールアドレスを空欄し、変更ボタンを押す
      fill_in 'email', with: ''
      click_on('変更する')
      # エラーメッセージが表示され、編集ページに戻されることを確認する
      expect(page).to have_current_path(user_path(@user))
      expect(page).to have_content('メールアドレスを入力してください')
      expect(page).to have_content('メールアドレスは不正な形式です')
      # 編集画面の項目がまだ存在することを確認する
      expect(page).to have_content('メールアドレス(必須)')
    end
  end

  context 'パスワードを変更できる時' do
    it 'パスワードと確認用パスワードを入力していれば変更できる' do
      log_in_and_visit_my_page
      click_btn_and_visit_edit_password_page

      # 新しいパスワードと確認用パスワードをそれぞれ入力する
      new_pw = 'NewPassword1234'
      fill_in 'password', with: new_pw
      fill_in 'password_confirmation', with: new_pw
      # 入力されたパスワードが正しいか、送信前にチェックを入れる
      expect(page).to have_field('password', with: new_pw)
      expect(page).to have_field('password_confirmation', with: new_pw)

      click_btn_and_visit_my_page_and_show_flash_message('変更する')
    end
  end

  context 'パスワードを変更できない時' do
    it 'パスワードや確認用パスワードが空欄だとエラーメッセージが表示され、変更できない' do
      log_in_and_visit_my_page
      click_btn_and_visit_edit_password_page

      # パスワードと確認用パスワードを空欄にする
      fill_in 'password', with: ''
      fill_in 'password_confirmation', with: ''

      # ｢変更する｣ボタンを押す
      click_on '変更する'

      # マイページへ遷移せず、エラーメッセージが表示されていることを確認する
      expect(page).to have_current_path(user_path(@user), wait: 10)
      expect(page).to have_selector('.error-message', text: 'パスワードを入力してください')
      # 編集画面の項目がまだ存在することを確認する
      expect(page).to have_content('新しいパスワード(必須)')
    end

    it '無効な入力内容（例：パスワード不一致）ではエラーメッセージが表示され、パスワードを変更できない' do
      log_in_and_visit_my_page
      click_btn_and_visit_edit_password_page

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
      expect(page).to have_current_path(user_path(@user), wait: 10)
      expect(page).to have_selector('.error-message', text: 'パスワード（確認用）とパスワードが一致しません')
      # 編集画面の項目がまだ存在することを確認する
      expect(page).to have_content('新しいパスワード(必須)')
    end
  end

  context 'アカウントを解約できる時' do
    it 'ログインユーザーはモーダルからマイページへ遷移し、アカウントを解約できる' do
      log_in_and_visit_my_page
      # マイページにアカウント解約ボタンがあることを確認する
      expect(page).to have_content('アカウントを解約する')
      # ボタンを押し、アカウント解約ページに遷移していることを確認する
      click_on('アカウントを解約する')
      expect(page).to have_current_path(cancel_user_path(@user), wait: 10)
      expect(page).to have_content('アカウント解約')

      # アカウント解約ページに最初の解約ボタンがあることを確認する
      expect(page).to have_content('解約する')
      # ボタンを押すと、最終確認のメッセージと最後の解約ボタンがあることを確認する
      find('#first-destroy-btn').click
      expect(page).to have_content("アカウントを本当に解約しますか？\n一度解約すると復元できません。")
      expect(page).to have_content('本当に解約する')

      # アンケートには回答せず、最後の解約ボタンを押す
      # ユーザーモデルのカウントが1減っていることと、アカウント解約完了ページに遷移していることを確認する
      expect do
        click_on('本当に解約する')
        # 解約完了後のパスに遷移するのを待機（これで処理完了を確実にする）
        expect(page).to have_current_path(cancel_completion_users_path, wait: 10)
      end.to change(User, :count).by(-1)

      # トップページに戻ると｢ログイン｣｢新規登録｣の文字があり、ユーザー名が表示されていないことを確認する
      click_on('トップページへ戻る')
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('ログイン')
      expect(page).to have_content('新規登録')
      expect(page).to have_no_content(@user.nickname)
    end
  end

  context 'アカウントを解約できない時' do
    it '未ログインユーザーはマイページへ遷移して、アカウントを解約できない' do
      not_log_in_user

      another_user = FactoryBot.create(:user)
      not_log_in_user_access_denied(user_path(another_user))
    end

    it 'ログインユーザーであっても別のユーザーのアカウントを解約できない' do
      another_user = FactoryBot.create(:user)
      log_in_user_access_denied(cancel_user_path(another_user))
    end

    it 'ユーザー本人であっても｢利用を継続する｣ボタンを押すとトップページへ遷移し、アカウントを解約できない' do
      # ログインし、直接アカウント解約ページへ遷移する
      login_as(@user)
      visit cancel_user_path(@user)

      # ｢利用を継続する｣ボタンを押す

      click_on('利用を継続する')
      expect(page).to have_current_path(root_path)
      expect(page).to have_no_content('アカウントを解約する')
    end
  end
end
