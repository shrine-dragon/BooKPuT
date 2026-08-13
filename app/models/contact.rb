class Contact < ApplicationRecord
  validates :name,  presence: true
  validates :email, presence: true,
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                    message: 'は不正な形式です' }
  validate  :email_domain_typo_check
  validates :message, presence: true, length: { maximum: 1000 }

  private

  def email_domain_typo_check
    return if email.blank?

    domain = email.split('@').last.to_s.downcase

    # gmail.com の打ち間違いっぽいパターンを弾く
    return unless domain.start_with?('gm') && domain != 'gmail.com'

    errors.add(:email, 'のドメイン(@以降)が正しくありません（例: gmail.com）')
  end
end
