class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    authorization
  end

  def twitter
    authorization
  end

  def facebook
    authorization
  end

  def line
    authorization
  end

  def failure
    redirect_to root_path, alert: '認証に失敗しました'
  end

  private

  def authorization
    puts '--- コントローラー通過！ ---'
    sns_info = User.from_omniauth(request.env['omniauth.auth'])
    @user = sns_info[:user]
    @user.sns_auth_process = true

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      # ここで「SNS認証経由である」という目印を立てる
      @sns_auth = true
      # SNSから取得した情報をsessionに保存（パスワード入力などを省くため）
      session['devise.sns_auth'] = sns_info[:sns].slice(:provider, :uid)
      render template: 'devise/registrations/new'
    end

    if @user.persisted?
      kind_name = I18n.t("devise.omniauth_providers.#{action_name}", default: action_name.capitalize)
      set_flash_message(:notice, :success, kind: kind_name) if is_navigational_format?
    else
      # 失敗時などは既存の処理
      session["devise.#{action_name}_data"] = request.env['omniauth.auth'].except(:extra)
    end
  end
end
