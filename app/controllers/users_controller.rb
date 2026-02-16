class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  # show以外は本人しかアクセスできないようにする
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
  end

  def edit
  end

  def update
    # パスワードの入力があるかどうかで処理を分ける
    if params[:user][:password].blank?
      # パスワードが空の場合、パスワード以外の項目を更新する
      if @user.update_without_password(user_params)
        redirect_to user_path(@user), notice: '更新しました'
      else
        render :edit
      end
    else
      # パスワードの入力がある場合は、通常通りバリデーションを通して更新
      if @user.update(user_params)
        redirect_to user_path(@user), notice: '更新しました'
      else
        render :edit
      end
    end
  end

  def destroy
    @user.destroy
  end

  private
  # ストロングパラメーター
  def user_params
    params.require(:user).permit(
      :nickname, :image, :birth_date, :gender_id, :email, 
      :password, :password_confirmation
    )
  end

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_correct_user
    redirect_to root_path if current_user != @user
  end
end
