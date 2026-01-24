class Users::RegistrationsController < Devise::RegistrationsController
  def new
    # GETリクエスト（新しくページを開いた時）かつ paramsがない時だけ消す
    if request.get? && params[:sns_auth] != 'true'
      session.delete("devise.sns_auth")
    end
    super
  end
end