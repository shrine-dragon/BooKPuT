class Users::RegistrationsController < Devise::RegistrationsController
  def new
    # GETリクエスト（新しくページを開いた時）かつ paramsがない時だけ消す
    session.delete('devise.sns_auth') if request.get? && params[:sns_auth] != 'true'
    super
  end
end
