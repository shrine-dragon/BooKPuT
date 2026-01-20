class Users::RegistrationsController < Devise::RegistrationsController

  def new
  # SNS認証ルート以外から来た場合は、念のためSNS用セッションを消す
  session.delete("devise.sns_auth") unless params[:sns_auth] == 'true'
  super
  end
end