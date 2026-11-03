class ContactMailer < ApplicationMailer
  default from: 'the.shrine.dragon@gmail.com'

  def send_mail(contact)
    @contact = contact

    @name = contact.name
    @email = contact.email
    @subject = contact.subject
    @message = contact.message

    mail(
      to: 'the.shrine.dragon@gmail.com', # 💡 あなたが「問い合わせを受け取りたい」Gmailアドレス
      subject: "【BooKPuT】お問い合わせ：#{@subject.present? ? @subject : '件名なし'}"
    )
  end
end
