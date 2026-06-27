class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:cancel_completion]
  before_action :set_user, except: [:cancel_completion]
  # show以外は本人しかアクセスできないようにする
  before_action :ensure_correct_user,
                only: %i[show edit_profile edit_email edit_password update destroy cancel cancel_completion]

  def show
    @my_books = @user.books.order(created_at: :desc)
    @my_good_books = @user.good_books.order(created_at: :desc)
    @my_favorite_books = @user.favorite_books.order(create_at: :desc)
  end

  def edit_profile; end

  def edit_email; end

  def edit_password; end

  def update
    # 画像削除フラグが '1' なら画像を削除する
    @user.image.purge if params[:user][:delete_image] == '1'

    # 「パスワード編集画面からの空送信」を絶対に許さない
    if params[:edit_type] == 'password' && params[:user][:password].blank?
      @user.errors.add(:password, 'を入力してください')
      render :edit_password and return # これ以上下のコードを読まずに、今すぐビューを返せ！」と強制命令
    end

    # 更新に使うパラメーターを決定する
    # パスワード編集時は delete しない、それ以外は空なら delete するロジック
    update_params = user_params_for_update

    result = if params[:edit_type] == 'password'
               # パスワード変更時は、バリデーションを「スキップしない」標準のupdateを使う
               @user.update(update_params)
             else
               # プロフィール編集時は、パスワードがなくても通るように従来通りスキップ
               @user.update_without_password(update_params)

               # update_without_password→パスワードのバリデーションをスキップするdevise独自のメソッド
             end

    # 保存処理
if result
      # パスワード変更の成功時
      if params[:edit_type] == 'password'
        bypass_sign_in(@user) 
        redirect_to user_path(@user), notice: 'パスワードを変更しました'
      # メールアドレス変更の成功時
      elsif params[:edit_type] == 'email'
        bypass_sign_in(@user) if respond_to?(:bypass_sign_in) 
        redirect_to user_path(@user), notice: 'メールアドレスを変更しました'
      # 通常のプロフィール変更の成功時
      else
        redirect_to user_path(@user), notice: 'プロフィールを更新しました'
      end
    else
      # 保存失敗時の戻り先分岐
      case params[:edit_type]
      when 'email' then render :edit_email
      when 'password' then render :edit_password
      else render :edit_profile
      end
    end
  end

  def cancel; end

  def destroy
    @user.destroy
    redirect_to cancel_completion_users_path
  end

  def cancel_completion; end

  private

  # ストロングパラメーター
  def user_params_for_update
    permitted = params.require(:user).permit(
      :nickname, :image, :birth_date, :gender_id, :email,
      :password, :password_confirmation
    )

    # パスワード編集ページ以外で、パスワードが空なら項目ごと削除（現在の挙動を維持）
    if params[:edit_type] != 'password' && permitted[:password].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end

    permitted
  end

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_correct_user
    redirect_to root_path if current_user != @user
  end
end
