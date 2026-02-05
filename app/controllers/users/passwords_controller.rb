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

  protected

  def after_sending_reset_password_instructions_path_for(resource_name)
    email_submitted_path
  end
end