class Book < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_one_attached :image
  belongs_to_active_hash :category

  validates :title, presence: true, length: { maximum: 100 }
  validates :category_id, presence: true, numericality: { other_than: 0, message: 'を選択してください' }
  validates :contents, presence: true
end
