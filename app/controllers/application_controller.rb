class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  private

  def configure_permitted_parameters
    # 新規登録時（sign_up）に許可するカラムを追加
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :birth_date, :gender_id, :image])
    
    # アカウント編集時（account_update）にも画像を許可する場合
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname, :image])
  end
end