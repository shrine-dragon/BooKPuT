class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      # ログイン失敗時：元のページに戻し、モーダル内にエラーを出させる
      flash[:alert] = 'メールアドレスまたはパスワードが違います'
      redirect_back(fallback_location: root_path)
    end
  end
end