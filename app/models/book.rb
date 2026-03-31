class Book < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :category
  has_one_attached :image
  # attr_accessor：外部から変数を参照したり、変更したりできるようになる
  attr_accessor :remote_image_url
  attr_accessor :delete_image

  attribute :genre_ids, :json, default: []

  has_many :book_contents, dependent: :destroy
  accepts_nested_attributes_for :book_contents, allow_destroy: true

  validates :title, presence: true, length: { maximum: 100 }
  validates :category_id, presence: true, numericality: { other_than: 0, message: 'を選択してください' }
  validates :book_contents, length: { minimum: 1, maximum: 7 }

  validate :genre_selection_limit
  
  validate :at_least_one_content

  before_validation :compact_book_contents

  private
  def genre_selection_limit
    # ジャンルが空の場合
    if genre_ids.blank? || genre_ids.all?(&:blank?)
      errors.add(:genre_ids, "を選択してください")
    # 3つより多い場合
    elsif genre_ids.reject(&:blank?).length > 3
      errors.add(:genre_ids, "を3つ以内で選択してください")
    end
  end


  def at_least_one_content
    if book_contents.reject { |c| c.content.blank? || c.marked_for_destruction? }.empty?
      errors.add(:book_contents, "を少なくとも1つ入力してください")
    end
  end

  def compact_book_contents
  # contentが空のものを、保存対象から除外する
    book_contents.each do |content|
      content.mark_for_destruction if content.content.blank?
    end
  end
end
