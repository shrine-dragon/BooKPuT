class BookBadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book

  def create
    return if @book.user_id == current_user.id

    current_user.book_goods.find_by(book_id: @book.id)&.destroy

    @book_bad = BookBad.create(user_id: current_user.id, book_id: @book.id)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @book.user_id == current_user.id

    @book_bad = BookBad.find_by(user_id: current_user.id, book_id: @book.id)
    @book_bad.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end
end