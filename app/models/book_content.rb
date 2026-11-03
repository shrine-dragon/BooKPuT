class BookContent < ApplicationRecord
  belongs_to :book
  validates :content, length: { maximum: 50 }

  private

  def first_content?
    book.book_contents.first == self
  end
end
