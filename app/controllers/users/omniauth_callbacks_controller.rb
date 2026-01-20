class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    authorization
   end

  def facebook
    authorization
  end

  def google_oauth2
    authorization
  end

  private

  def authorization
    sns_info = User.from_omniauth(request.env["omniauth.auth"])
    @user = sns_info[:user]

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      # ここで「SNS認証経由である」という目印を立てる
      @sns_auth = true
      # SNSから取得した情報をsessionに保存（パスワード入力などを省くため）
      session["devise.sns_auth"] = sns_info[:sns].slice(:provider, :uid)
      render template: 'devise/registrations/new'
    end
  end
end
