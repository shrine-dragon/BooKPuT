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
      OmniAuth.config.on_failure = Proc.new { |env|
        env['devise.mapping'] = Devise.mappings[:user]
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      }
    end

    after do
      OmniAuth.config.test_mode = false
    end
  end

  def open_sign_up_modal
    # トップページに遷移する
    visit root_path

    # 初期状態ではモーダルが表示されていないことを確認する
    expect(page).to have_no_selector('.modal.sign-up', visible: true)

    # ページ内に「新規登録」の文字があることを確認する
    signup_target = find('.sign-up-menu-text', text: '新規登録', visible: :all)

    # 画面をスクロールさせる
    execute_script('arguments[0].scrollIntoView({block: "center"});', signup_target)
    # 0.5秒待機する
    sleep 0.5
    # menuの代わりにモーダルを表示状態(block)にするJSを実行
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

    execute_script('document.getElementById("sns_auth_process").value = "true";') if has_selector?('#sns_auth_process', visible: false)
  end

  def return_to_top_page_and_change_display(user_number, flash_message_text, selector)
    expect(page).to have_selector(selector, wait: 10)

    expect{
      scroll_display(selector)
    }.to change { User.count }.by(user_number)
    expect(page).to have_current_path(root_path, wait: 15)

    #トップページにフラッシュメッセージが表示されていることを確認する
    expect(page).to have_selector('.flash-message', text: flash_message_text)
    #トップページに｢新規登録｣｢ログイン｣のmenuテキストが表示されていないことを確認する
    expect(page).to have_no_selector('.sign-up-menu-text', text: '新規登録')
    expect(page).to have_no_selector('.log-in-menu-text', text: 'ログイン')
    # トップページにユーザー名が表示されていることを確認する
    expect(page).to have_content(@user.nickname)
  end

  def return_to_top_page_and_show_flash_message
    # 認証失敗後はトップページに遷移し、フラッシュメッセージが表示されることを確認する
    expect(page).to have_current_path(root_path, wait: 10)
    expect(page).to have_selector('.flash-message', text: '認証に失敗しました')
  end

  def open_log_in_modal
    # トップページに遷移する
    visit root_path

    # 初期状態ではモーダルが表示されていないことを確認する
    expect(page).to have_no_selector('.modal.log-in', visible: true)

    # ページ内に「ログイン」の文字があることを確認する
    login_target = find('.log-in-menu-text', text: 'ログイン', visible: :all)

    # 画面をスクロールさせる
    execute_script('arguments[0].scrollIntoView({block: "center"});', login_target)
    # 0.5秒待機する
    sleep 0.5
    # menuの代わりにモーダルを表示状態(block)にするJSを実行
    execute_script('document.querySelector(".modal.log-in").style.display = "block";')
    # モーダルが表示されたことを確認する
    expect(page).to have_selector('.modal.log-in', visible: true)
  end

  def click_btn_and_no_change
    # 「ログイン」ボタンを押してもユーザー名が表示されていないことを確認する
    scroll_display(".log-in-submit-btn")
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
end
