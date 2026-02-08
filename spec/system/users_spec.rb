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

      submit_and_expect_success(".cyan-submit-btn", 1, "登録が完了しました")
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
      submit_and_expect_success(".cyan-submit-btn", 1, "登録が完了しました")
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
      submit_and_expect_success(".cyan-submit-btn", 1, "登録が完了しました")
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
      submit_and_expect_success(".cyan-submit-btn", 1, "登録が完了しました")
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
      submit_and_expect_success(".cyan-submit-btn", 1, "登録が完了しました")
    end
  end

  context 'SNSでユーザー新規登録ができない時' do
    it 'Google連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      # Google認証の失敗をシミュレート
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      open_sign_up_modal
      click_link 'Google'

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end

    it 'X(Twitter)連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

      open_sign_up_modal
      click_link 'X(Twitter)'

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end

    it 'Facebook連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

      open_sign_up_modal
      click_link 'Facebook'

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end

    it 'LINE連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:line] = :invalid_credentials

      open_sign_up_modal
      click_link 'LINE'

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
      open_log_in_modal
      # 必須事項を入力する
      fill_in 'email',      with: @user.email
      fill_in 'password',   with: @user.password

      submit_and_expect_success(".log-in-submit-btn", 0, "ログインしました")
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
      submit_and_expect_success("#google-log-in", 0, "Google アカウントでログインしました。")
    end

    it 'X(Twitter)認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:twitter)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      submit_and_expect_success("#twitter-log-in", 0, "X アカウントでログインしました。")
    end

    it 'Facebook認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:facebook)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      submit_and_expect_success("#facebook-log-in", 0, "Facebook アカウントでログインしました。")
    end

    it 'LINE認証が成功すればログインでき、トップページに遷移する' do
      create_log_in_mock_data(:line)
      open_log_in_modal
      # トップページに遷移し、成功用のフラッシュメッセージが表示されていることを確認する
      submit_and_expect_success("#line-log-in", 0, "LINE アカウントでログインしました。")
    end
  end

  context 'SNSでログインができない時' do
    it 'Google認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#google-log-in")

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end

    it 'X(twitter)認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#twitter-log-in")

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end

    it 'Facebook認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#facebook-log-in")

      return_to_top_page_and_show_flash_message('認証に失敗しました')
    end

    it 'LINE認証をキャンセルするとログインできず、トップページに戻る' do
      OmniAuth.config.mock_auth[:line] = :invalid_credentials

      open_log_in_modal
    
      scroll_display("#line-log-in")

      return_to_top_page_and_show_flash_message('認証に失敗しました')
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
      open_log_in_modal
      scroll_display(".forget-password")

      #パスワード再設定ページに遷移していることを確認する
      expect(page).to have_current_path("/users/password/new", wait: 5)
      # フィールドが出るまで最大5秒待つ
      expect(page).to have_field('email', wait: 5)

      # 登録済みのメールアドレスを入力する
      fill_in 'email', with:  @user.email
      # 入力されたメールアドレスが正しいか、送信前にチェックを入れる
      expect(page).to have_field('email', with: @user.email)
      click_on('送信する')

      #メール送信完了ページに遷移していることを確認する
      expect(page).to have_current_path("/passwords/email_submitted")

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
      expect(page).to have_current_path("/passwords/updated")
      expect(page).to have_content("パスワードの変更が完了しました。")

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
      expect(page).to have_current_path("/users/password", wait: 10)
      expect(page).to have_selector(".error-message", text: 'メールアドレスを入力してください')
    end

    it '未登録のメールアドレスを入力するとパスワード再設定用のメールは届かず、パスワードも変更できない' do
      # パスワード再設定のためのメールアドレス入力ページへ遷移する
      visit new_user_password_path

      # 未登録のメールアドレスを入力にして｢送信する｣ボタンを押すが、パスワード再設定用のメールが届いていないことを確認する
      fill_in 'email', with: 'non-registered@example.com'
      expect {
        click_on('送信する')
      }.to change { ActionMailer::Base.deliveries.size }.by(0)

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
      fill_in 'password_confirmation', with: new_pw + '5'

      # 入力されたパスワードが正しいか、送信前にチェックを入れる
      expect(page).to have_field('password', with: new_pw)
      expect(page).to have_field('password_confirmation', with: new_pw + '5')

      # ｢変更する｣ボタンを押す
      click_on '変更する'

      # パスワード変更完了ページへ遷移せず、エラーメッセージが表示されていることを確認する
      expect(page).to have_current_path("/users/password", wait: 10)
      expect(page).to have_selector(".error-message", text: 'パスワード（確認用）とパスワードが一致しません')
    end
  end
end