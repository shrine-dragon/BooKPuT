module UserSupport
  extend ActiveSupport::Concern

  included do
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

  def close_modal(selector_type, _header_menu_text, not_modal_selector)
    # モーダル以外の部分にカーソルを置く
    find(not_modal_selector).hover
    # モーダルが非表示になってしまうことを確認する
    expect(page).to have_no_selector(".modal.#{selector_type}", wait: 5)
  end

  def visit_sign_up_page
    # 新規登録用モーダルに｢メールアドレスでアカウント作成｣のボタンがあることを確認する
    expect(page).to have_content('メールアドレスでアカウント作成')
    # ボタンをクリックする
    click_link 'メールアドレスでアカウント作成'

    # 新規登録ページに遷移したことを確認する
    expect(page).to have_current_path(new_user_registration_path)
    expect(page).to have_content '新規登録フォーム'
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

    # 今DBに保存されたばかりの最新ユーザーを取得する
    latest_user = User.last

    # トップページにフラッシュメッセージが表示されていることを確認する
    expect(page).to have_selector('.flash-message', text: flash_message)

    # トップページに｢新規登録｣｢ログイン｣のmenuテキストが表示されていないことを確認する
    expect(page).to have_no_selector('.sign-up-menu-text', text: '新規登録')
    expect(page).to have_no_selector('.log-in-menu-text', text: 'ログイン')

    # ヘッダーに登録したニックネームと画像が表示されていることを確認する
    expect(page).to have_selector('.user-nickname', text: @user.nickname, visible: false)
    if latest_user.image.attached?
      expect(page).to have_selector('.user-image')
    else
      expect(page).to have_selector('.user-image.no-exist')
    end
  end

  def toggle_password(password_text, password_confirmation_text)
    # パスワードの入力欄が最初は非表示（type="password"）であることを確認する
    expect(page).to have_selector('#password[type="password"]')

    # 確認用パスワードがある場合のみ確認する
    has_confirmation = page.has_selector?('#password_confirmation')
    expect(page).to have_selector('#password_confirmation[type="password"]') if has_confirmation

    # 全てのパスワード可視化アイコンをクリックする
    all('.toggle-password').each(&:click)

    # パスワードと確認用パスワード(あれば)が表示状態になっていることを確認する

    icon_count = has_confirmation ? 2 : 1
    expect(page).to have_selector('.fa-eye.toggle-password', count: icon_count)
    expect(page).to have_selector('#password[type="text"]')
    expect(page.find('#password').value).to eq password_text

    if has_confirmation
      expect(page).to have_selector('#password_confirmation[type="text"]')
      expect(page.find('#password_confirmation').value).to eq password_confirmation_text
    end

    # 再度アイコンを押すとパスワードと確認用パスワード(あれば)が非表示になることを確認する
    all('.fa-eye.toggle-password').each(&:click)
    expect(page).to have_selector('#password[type="password"]')

    return unless has_confirmation

    expect(page).to have_selector('#password_confirmation[type="password"]')
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

  def get_token_and_visit_edit_password_page
    # メール送信によってDBに保存された「生のトークン」を直接取得する
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.update(reset_password_token: hashed_token, reset_password_sent_at: Time.now.utc)
    # トークンを使って編集ページへ直接行く
    visit edit_user_password_path(reset_password_token: raw_token)
  end

  def log_in_and_show_modal
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
  end

  def log_in_and_visit_my_page
    log_in_and_show_modal
    visit_my_page
  end

  def show_account_info
    # マイページにアカウント情報が表示されていることを確認する
    expect(page).to have_selector('.user-nickname', text: @user.nickname, visible: false)
    expect(page).to have_selector('.current-user-image')
    expect(page).to have_content(@user.birth_date.strftime('%Y/%m/%d'))
    expect(page).to have_content(@user.gender.name)
  end

  def show_log_in_info
    # マイページにログイン情報が表示されていることを確認する
    expect(page).to have_content(@user.masked_email)
    expect(page).to have_content('********')
  end

  def not_log_in_user
    # トップページに｢ログイン｣｢新規登録｣の文字があり、未ログインの状態であることを確認する
    visit root_path
    expect(page).to have_selector('.log-in-menu-text', text: 'ログイン', visible: false)
    expect(page).to have_selector('.sign-up-menu-text', text: '新規登録', visible: false)
    # トップページにユーザーのニックネームが表示されていないことを確認する
    expect(page).to have_no_content(@user.nickname)
  end

  def click_btn_and_visit_my_page_and_show_flash_message(btn_text)
    # ボタンを押す
    click_on(btn_text)
    # マイページに遷移し、フラッシュメッセージが表示されていることを確認する
    expect(page).to have_current_path(user_path(@user), wait: 10)
    expect(page).to have_selector('.flash-message', text: '更新しました')
  end

  def click_btn_and_check_account_info
    # 編集ボタンを押すとプロフィール編集ページに遷移することを確認する
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
    # 変更ボタンを押すとメールアドレス変更ページに遷移することを確認する
    click_on('メールアドレスを変更する')
    expect(page).to have_current_path(edit_email_user_path(@user))

    # すでに登録済みのアカウント情報がフォームに入っていることを確認する
    expect(
      find('#email').value
    ).to eq(@user.email)
  end

  def click_btn_and_visit_edit_password_page
    # 変更ボタンを押すとパスワード変更ページに遷移することを確認する
    click_on('パスワードを変更する')
    expect(page).to have_current_path(edit_password_user_path(@user))
  end
end
