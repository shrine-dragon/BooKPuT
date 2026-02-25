class BookContent < ApplicationRecord
  belongs_to :book
  validates :content, presence: true, length: { maximum: 140 }
end