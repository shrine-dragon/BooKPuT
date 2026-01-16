class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :image
  belongs_to_active_hash :gender
  
  validates :gender_id, numericality: { other_than: 0, message: 'を選択してください' }
end
