class Contact < ApplicationRecord
  validates :name,    presence: true
  validates :email,   presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'は不正な形式です' }
  validates :message, presence: true, length: { maximum: 1000 }
end
