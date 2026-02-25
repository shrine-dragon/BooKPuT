class CustomFailureApp < Devise::FailureApp
  def recall
    flash.now[:alert] = nil
    super
  end
end