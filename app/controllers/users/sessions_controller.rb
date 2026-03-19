# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # 1. ユーザー認証を試みる
    self.resource = warden.authenticate(auth_options)

    if resource
      # ログイン成功時
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      # ログイン失敗時：リダイレクトしてエラーメッセージを渡す
      flash[:alert] = 'メールアドレスまたはパスワードが違います'
      redirect_back(fallback_location: root_path) # 元のページへ戻す
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
