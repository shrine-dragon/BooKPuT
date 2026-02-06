# spec/system/users_spec.rb
require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
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

      return_to_top_page_and_change_display(1, "登録が完了しました", ".cyan-submit-btn")
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
        scroll_display(".cyan-submit-btn")
      }.to change { User.count }.by(0)
      # 新規登録ページへ戻されることを確認する
      expect(page).to have_current_path("/users")
      # エラーメッセージが表示されていることを確認する
      expect(page).to have_content 'ニックネームを入力してください'
    end
  end

  context 'SNSでユーザー新規登録ができる時' do
    it 'Google連携後に必要な情報を入力すれば登録でき、トップページに移動する' do
      # モック(偽の)データを一度クリアする
      OmniAuth.config.mock_auth[:google_oauth2] = nil
      # SNS認証用にパスワードを空にした状態のオブジェクトを作る
      # バリデーションエラーを確実に回避可能
      @user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
      
      auth_hash = OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: SecureRandom.uuid, # UIDも念のため被らないようにする
        info: { nickname: @user.nickname, email: @user.email }
      })
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
      
      open_sign_up_modal
      click_link 'Google'

      input_info_and_sign_up('google_oauth2')
      return_to_top_page_and_change_display(1, "登録が完了しました", ".cyan-submit-btn")
    end

    it 'X(Twitter)連携後に必要な情報を入力すれば登録でき、トップページに移動する' do
      # モック(偽の)データを一度クリアする
      OmniAuth.config.mock_auth[:twitter] = nil
      # SNS認証用にパスワードを空にした状態のオブジェクトを作る
      # バリデーションエラーを確実に回避可能
      @user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
      
      auth_hash = OmniAuth::AuthHash.new({
        provider: 'twitter',
        uid: SecureRandom.uuid, # UIDも念のため被らないようにする
        info: { nickname: @user.nickname, email: @user.email }
      })
      OmniAuth.config.mock_auth[:twitter] = auth_hash
      
      open_sign_up_modal
      click_link 'X(Twitter)'

      input_info_and_sign_up('twitter')
      return_to_top_page_and_change_display(1, "登録が完了しました", ".cyan-submit-btn")
    end

    it 'Facebook連携後に必要な情報を入力すれば登録でき、トップページに移動する' do
      # モック(偽の)データを一度クリアする
      OmniAuth.config.mock_auth[:facebook] = nil
      @user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
      
      auth_hash = OmniAuth::AuthHash.new({
        provider: 'facebook',
        uid: SecureRandom.uuid,
        info: { nickname: @user.nickname, email: @user.email }
      })
      OmniAuth.config.mock_auth[:facebook] = auth_hash
      
      open_sign_up_modal
      click_link 'Facebook'

      input_info_and_sign_up('facebook')
      return_to_top_page_and_change_display(1, "登録が完了しました", ".cyan-submit-btn")
    end

    it 'LINE連携後に必要な情報を入力すれば登録でき、トップページに移動する' do
      # モック(偽の)データを一度クリアする
      OmniAuth.config.mock_auth[:line] = nil

      @user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
      
      auth_hash = OmniAuth::AuthHash.new({
        provider: 'line',
        uid: SecureRandom.uuid,
        info: { nickname: @user.nickname, email: @user.email }
      })
      OmniAuth.config.mock_auth[:line] = auth_hash
      
      open_sign_up_modal
      click_link 'LINE'

      input_info_and_sign_up('line')
      return_to_top_page_and_change_display(1, "登録が完了しました", ".cyan-submit-btn")
    end
  end

  context 'SNSでユーザー新規登録ができない時' do
    it 'Google連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      # Google認証の失敗をシミュレート
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      open_sign_up_modal
      click_link 'Google'

      return_to_top_page_and_show_flash_message
    end

    it 'X(Twitter)連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

      open_sign_up_modal
      click_link 'X(Twitter)'

      return_to_top_page_and_show_flash_message
    end

    it 'Facebook連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

      open_sign_up_modal
      click_link 'Facebook'

      return_to_top_page_and_show_flash_message
    end

    it 'LINE連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:line] = :invalid_credentials

      open_sign_up_modal
      click_link 'LINE'

      return_to_top_page_and_show_flash_message
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'メールアドレスでログインができる時' do
    it '正しい情報を入力すればログインでき、トップページに移動する' do
      open_log_in_modal
      # 必須事項を入力する
      fill_in 'email',      with: @user.email
      fill_in 'password',   with: @user.password

      return_to_top_page_and_change_display(0, "ログインしました", ".log-in-submit-btn")
    end
  end

  context 'メールアドレスでログインができない時' do
    it '必須項目が空欄のままボタンを押してもログインできない' do
      open_log_in_modal
      # 必須事項を空欄にする
      fill_in 'email',      with: ''
      fill_in 'password',   with: ''
      click_btn_and_no_change
    end

    it '入力情報が登録情報と異なる状態でボタンを押してもログインできず、エラーメッセージが表示される' do
      open_log_in_modal
      # 異なる情報を入力する
      fill_in 'email',    with: "wrong_#{@user.email}"
      fill_in 'password', with: "wrong_password"
      click_btn_and_no_change
      expect(page).to have_content('メールアドレスまたはパスワードが違います。')
    end
  end

  context 'SNSでログインができる時' do
    it 'Google認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:google_oauth2)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      return_to_top_page_and_change_display(0, "Google アカウントでログインしました。", "#google-log-in")
    end

    it 'X(Twitter)認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:twitter)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      return_to_top_page_and_change_display(0, "X アカウントでログインしました。", "#twitter-log-in")
    end

    it 'Facebook認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:facebook)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      return_to_top_page_and_change_display(0, "Facebook アカウントでログインしました。", "#facebook-log-in")
    end

    it 'LINE認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:line)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      return_to_top_page_and_change_display(0, "LINE アカウントでログインしました。", "#line-log-in")
    end
  end

  context 'SNSでログインができない時' do
    it 'Google認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#google-log-in")

      return_to_top_page_and_show_flash_message
    end

    it 'X(twitter)認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#twitter-log-in")

      return_to_top_page_and_show_flash_message
    end

    it 'Facebook認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#facebook-log-in")

      return_to_top_page_and_show_flash_message
    end

    it 'LINE認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:line] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#line-log-in")

      return_to_top_page_and_show_flash_message
    end
  end

  context 'パスワードの変更ができる時' do
    it '未ログインの状態でパスワード再設定ページへ遷移し、正しい情報を入力すればパスワードを変更できる' do
      open_log_in_modal
      scroll_display(".forget-password")

      #パスワード再設定ページに遷移していることを確認する
      expect(page).to have_current_path("/users/password/new")
      # 登録済みのメールアドレスを入力し、送信ボタンを押す
      fill_in 'email', with:  @user.email
      click_on('送信する')

      #メール送信完了ページに遷移していることを確認する
      expect(page).to have_current_path("/passwords/email_submitted")

      # メール送信によってDBに保存された「生のトークン」を直接取得する
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      @user.update(reset_password_token: hashed_token, reset_password_sent_at: Time.now.utc)
      # トークンを使って編集ページへ直接行く
      visit edit_user_password_path(reset_password_token: raw_token)
      
      # 新しいパスワードを入力して更新する
      fill_in 'password', with: 'NewPassword1234'
      fill_in 'password_confirmation', with: 'NewPassword1234'
      click_on '変更する'

      # パスワード変更完了ページに遷移していることを確認する
      expect(page).to have_current_path("/passwords/updated")
      expect(page).to have_content("パスワードの変更が完了しました。")

      # トップページへ戻り、ログインできている（＝ニックネームがある）ことを確認する
      click_on 'トップページへ戻る'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(@user.nickname)
    end
  end

  context 'パスワードの変更ができない時' do
    
  end
end

RSpec.describe 'ログアウト', type: :system do
end