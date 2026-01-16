class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :image
  belongs_to_active_hash :gender

  with_options presence: true do
    validates :nickname, length: { minimum: 4, maximum: 16 }
    validates :birth_date
    validates :password, length: { minimum: 8, maximum: 20 },
                         format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i, message: 'は半角英数混合で入力してください' },
                         allow_blank: true
    validates :password_confirmation
  end
  
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'は不正な形式です' }, allow_blank: true
  validates :gender_id, numericality: { other_than: 0, message: 'を選択してください' }
end
