class ContactsController < ApplicationController
  def new; end

  def create
    # パラメータを受け取る
    @name    = params[:name]
    @email   = params[:email]
    @subject = params[:subject]
    @message = params[:message]

    @errors = {}
    @errors[:name]    = "氏名を入力してください" if @name.blank?
    @errors[:email]   = "メールアドレスを入力してください" if @email.blank?
    @errors[:message] = "メッセージ本文を入力してください" if @message.blank?

    # 🔴 エラーが1つでもあれば、flashを使わずにそのまま再描画
    if @errors.any?
      render :new and return
    end

    ContactMailer.send_mail(@name, @email, @subject, @message).deliver_now

    redirect_to root_path
  end
end