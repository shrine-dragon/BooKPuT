module UserSupport
  extend ActiveSupport::Concern

  included do
    before do
      # ブラウザが実際に動く様子が見えるモード
      # 最初からウィンドウサイズを指定
      driven_by :selenium_chrome do |driver_option|
        driver_option.add_argument('--window-size=1280,1024')
      end

      OmniAuth.config.test_mode = true
      # 失敗時に例外を投げず、callback用のURLにリダイレクトさせる設定
      OmniAuth.config.on_failure = proc do |env|
        env['devise.mapping'] = Devise.mappings[:user]
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      end
    end

    after do
      OmniAuth.config.test_mode = false
      Warden.test_reset!
    end
  end

  def open_modal(selector_type, header_menu_text)
    visit root_path

    # 初期状態ではモーダルが表示されていないことを確認する
    expect(page).to have_no_selector(".modal.#{selector_type}", visible: true)

    # ページ内に｢新規登録｣または「ログイン」の文字があることを確認する
    target = find(".#{selector_type}-menu-text", text: header_menu_text, visible: :all)

    # 画面をスクロールさせる
    execute_script('arguments[0].scrollIntoView({block: "center"});', target)

    sleep 0.5

    # モーダルを表示状態(block)にするJSを実行
    execute_script("document.querySelector('.modal.#{selector_type}').style.display = 'block';")

    # モーダルが表示されたことを確認する
    expect(page).to have_selector(".modal.#{selector_type}", visible: true)
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

  def scroll_display(selector_or_text)
    # セレクタ（#や.）でなければテキストとして探す
    element = if selector_or_text.start_with?('#', '.')
                find(selector_or_text, wait: 10, visible: :all)
              else
                # text: selector_or_text を match: :first にするか、
                # リンク内のテキストが含まれているものを探すように変更
                find('a', text: selector_or_text, wait: 10, visible: :all)
              end

    execute_script('arguments[0].scrollIntoView({block: "center"});', element)
    sleep 0.5
    # 強制的にクリック
    execute_script('arguments[0].click();', element)
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

    execute_script('document.getElementById("sns_auth_process").value = "true";') if has_selector?('#sns_auth_process',
                                                                                                   visible: false)
  end

  def submit_and_expect_success(selector, count_change, flash_message)
    expect do
      scroll_display(selector)
    end.to change { User.count }.by(count_change)

    verify_top_page_after_login(flash_message)
  end

  def verify_top_page_after_login(flash_message)
    expect(page).to have_current_path(root_path, wait: 15)

    # トップページにフラッシュメッセージが表示されていることを確認する
    expect(page).to have_selector('.flash-message', text: flash_message)

    # トップページに｢新規登録｣｢ログイン｣のmenuテキストが表示されていないことを確認する
    expect(page).to have_no_selector('.sign-up-menu-text', text: '新規登録')
    expect(page).to have_no_selector('.log-in-menu-text', text: 'ログイン')
    # トップページにユーザー名が表示されていることを確認する
    expect(page).to have_content(@user.nickname)
  end

  def return_to_top_page_and_show_flash_message(flash_message)
    # トップページに遷移し、フラッシュメッセージが表示されることを確認する
    expect(page).to have_current_path(root_path, wait: 10)
    expect(page).to have_selector('.flash-message', text: flash_message)
  end

  def click_btn_and_no_change
    # 「ログイン」ボタンを押してもユーザー名が表示されていないことを確認する
    scroll_display('.log-in-submit-btn')
    # ページが遷移していない（＝ログイン後のトップページにいない）ことを確認する
    # トップページにユーザーのニックネームが表示されていないことを確認する
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_content(@user.nickname)
  end

  def create_log_in_mock_data(provider)
    # モックデータを作成
    OmniAuth.config.mock_auth[provider.to_sym] = OmniAuth::AuthHash.new({
                                                                          provider: provider.to_s,
                                                                          uid: '123456',
                                                                          info: {
                                                                            name: @user.nickname,
                                                                            email: @user.email
                                                                          }
                                                                        })
  end

  def get_token_and_access_edit_password_page
    # メール送信によってDBに保存された「生のトークン」を直接取得する
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.update(reset_password_token: hashed_token, reset_password_sent_at: Time.now.utc)
    # トークンを使って編集ページへ直接行く
    visit edit_user_password_path(reset_password_token: raw_token)
  end

  def log_in_and_show_modal
    # 最初からログイン状態にし、トップページへ遷移する
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
  end

  def not_log_in_user
    # トップページに｢ログイン｣｢新規登録｣の文字があり、未ログインの状態であることを確認する
    visit root_path
    expect(page).to have_content('ログイン')
    expect(page).to have_content('新規登録')
    # トップページにユーザーのニックネームが表示されていないことを確認する
    expect(page).to have_no_content(@user.nickname)
  end

  def log_in_and_visit_my_page
    login_as(@user)
    visit user_path(@user)
  end

  def click_btn_and_visit_my_page_and_show_flash_message(btn_text)
    # ボタンを押す
    click_on(btn_text)
    # マイページに遷移し、フラッシュメッセージが表示されていることを確認する
    expect(page).to have_current_path(user_path(@user), wait: 10)
    expect(page).to have_selector('.flash-message', text: '更新しました')
  end

  def click_btn_and_check_account_info
    # 編集ボタンを押すとプロフィール編集ページへ遷移することを確認する
    click_on('プロフィールを編集する')
    expect(page).to have_current_path(edit_profile_user_path(@user))

    # すでに登録済みのアカウント情報がフォームに入っていることを確認する
    expect(
      find('#nickname').value
    ).to eq(@user.nickname)
    expect(
      find('#birth_date').value
    ).to eq(@user.birth_date.to_s)
    expect(
      find('#gender').value
    ).to eq(@user.gender_id.to_s)
  end

  def click_btn_and_check_email
    # 変更ボタンを押すとメールアドレス変更ページへ遷移することを確認する
    click_on('メールアドレスを変更する')
    expect(page).to have_current_path(edit_email_user_path(@user))

    # すでに登録済みのアカウント情報がフォームに入っていることを確認する
    expect(
      find('#email').value
    ).to eq(@user.email)
  end

  def click_btn_and_visit_edit_password_page
    # 変更ボタンを押すとパスワード変更ページへ遷移することを確認する
    click_on('パスワードを変更する')
    expect(page).to have_current_path(edit_password_user_path(@user))
  end
end
