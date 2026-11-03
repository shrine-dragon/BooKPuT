class CustomFailureApp < Devise::FailureApp
  def redirect_url
    root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      # 謎のエラーメッセージを消し、代わりにJS判定用の目印をflashに入れる
      flash[:alert] = 'force_login'
      redirect
    end
  end
end
