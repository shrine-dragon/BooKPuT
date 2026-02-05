# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  protected

  def email_submitted
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:notice] = nil
    email_submitted_path
  end
end
