class ContactsController < ApplicationController
  def new; end

  def create
    # パラメータを受け取る
    @name    = params[:name]
    @email   = params[:email]
    @subject = params[:subject]
    @message = params[:message]

    # バリデーション（空チェックなど）を簡易的に行う場合
    if @name.blank? || @message.blank?
      flash.now[:alert] = "氏名とメッセージ本文は必須入力です。"
      render :new and return
    end

    # 💡 ここでメール送信処理を呼び出す（パターン②なら、この1行を消すだけでOK！）
    # ContactMailer.send_mail(@name, @email, @subject, @message).deliver_now

    redirect_to root_path, notice: "お問い合わせを送信しました。"
  end
end