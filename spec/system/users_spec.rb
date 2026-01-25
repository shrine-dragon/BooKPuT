# spec/system/users_spec.rb
require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    # ブラウザが実際に動く様子が見えるモード
    driven_by :selenium_chrome
    page.driver.browser.manage.window.resize_to(1280, 1024)
    @user = FactoryBot.build(:user)

    OmniAuth.config.test_mode = true
    # 失敗時に例外を投げず、callback用のURLにリダイレクトさせる設定
    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
  end

  after do
    OmniAuth.config.test_mode = false
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

  def scroll_display
    submit_btn = find('input[name="commit"]', wait: 5)
    # JavaScriptで強制的にクリックする
    execute_script('arguments[0].scrollIntoView({block: "center"});', submit_btn)
    sleep 2.0
    page.execute_script('arguments[0].click();', submit_btn)
  end

  def input_info_and_sign_up(provider)
    expect(page).to have_current_path("/users/auth/#{provider}/callback", wait: 10)
    expect(page).to have_content('新規登録フォーム', wait: 10)

    # 必須事項を入力または選択する
    # ニックネームとメールが空なら補完
    fill_in 'nickname', with: @user.nickname if find('#nickname').value.blank?
    fill_in 'birth_date', with: @user.birth_date.strftime('%Y-%m-%d')
    select @user.gender.name, from: 'gender'
    fill_in 'email', with: random_email if find('#email').value.blank?

    execute_script('document.getElementById("sns_auth_process").value = "true";') if has_selector?('#sns_auth_process', visible: false)

    scroll_display
    expect(page).to have_current_path(root_path, wait: 15)
    expect(User.count).to eq 1

    # トップページに「新規登録」テキストが表示されていないことを確認する
    # expect(page).to have_no_content('新規登録') 未実装
    # トップページにユーザー名が表示されていることを確認する
    # expect(page).to have_content(@user.nickname) 未実装
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
        scroll_display
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
        scroll_display
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
    end
  end

  context 'SNSでユーザー新規登録ができない時' do
    it 'Google連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      # Google認証の失敗をシミュレート
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      open_sign_up_modal
      click_link 'Google'

      # 認証失敗後、元のページ（または指定したリダイレクト先）に戻ることを確認する
      expect(page).to have_current_path(root_path, wait: 10)
      # 失敗メッセージやモーダルが残っているかなどを確認（アプリの実装に合わせて変更）
      # expect(page).to have_content '認証に失敗しました' 
    end

    it 'Facebook連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

      open_sign_up_modal
      click_link 'Facebook'

      expect(page).to have_current_path(root_path, wait: 10)
    end

    it 'LINE連携をキャンセルすると、新規登録モーダルがあるページに戻る' do
      OmniAuth.config.mock_auth[:line] = :invalid_credentials

      open_sign_up_modal
      click_link 'LINE'

      expect(page).to have_current_path(root_path, wait: 10)
    end
  end
end