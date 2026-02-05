class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, only: [:updated]

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    
    if resource.errors.added?(:email, :blank)
      render :new
    else
      flash[:notice] = nil
      redirect_to email_submitted_path
    end
  end

  def edit
    super
  end

  def updated
    flash.clear
  end

  def update
    self.resource = resource_class.reset_password_by_token(reset_password_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)

      if Devise.sign_in_after_reset_password
        # bypass: true セッションを維持したまま認証情報を更新可能
        sign_in(resource_name, resource, bypass: true)
      end
      flash.clear
      redirect_to updated_path and return
    else
      set_minimum_password_length
      render :edit
    end
  end

  private
  def reset_password_params
    params.require(:user).permit(:password, :password_confirmation, :reset_password_token)
  end

  protected

  def after_sending_reset_password_instructions_path_for(resource_name)
    email_submitted_path
  end

  def after_resetting_password_path_for(resource)
    updated_path
  end
end