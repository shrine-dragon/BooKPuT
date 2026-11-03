class Comment < ApplicationRecord
  validates  :text, presence: true, length: { maximum: 100 }
  belongs_to :user
  belongs_to :book
  has_many :hidden_comments,   dependent: :destroy
  has_many :reported_comments, dependent: :destroy
  has_many :comment_goods,     dependent: :destroy
  has_many :comment_bads,      dependent: :destroy
end
