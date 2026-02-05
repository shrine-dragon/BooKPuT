class Users::PasswordsController < Devise::PasswordsController

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

  def update
    self.resource = resource_class.reset_password_by_token(reset_password_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
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
    root_path
  end
end