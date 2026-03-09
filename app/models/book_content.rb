class BookContent < ApplicationRecord
  belongs_to :book

  with_options if: :first_content? do
    validates :content, presence: true, length: { minimum: 20, maximum: 50 }
  end

  private

  def first_content?
    book.book_contents.first == self
  end
end