class Book < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :category
  has_one_attached :image
  has_many :book_contents, dependent: :destroy

  accepts_nested_attributes_for :book_contents, allow_destroy: true, reject_if: :all_blank

  validates :book_contents, length: { minimum: 1, maximum: 7 }

  validates :title, presence: true, length: { maximum: 100 }
  validates :category_id, presence: true, numericality: { other_than: 0, message: 'を選択してください' }
end
