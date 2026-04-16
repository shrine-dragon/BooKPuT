class Comment < ApplicationRecord
  validates  :text, presence: true, length: { maximum: 100 }
  belongs_to :user
  belongs_to :book
end
