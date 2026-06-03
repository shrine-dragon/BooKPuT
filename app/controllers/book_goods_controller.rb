class BookGoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book

  def create
    return if @book.user_id == current_user.id

    current_user.book_bads.find_by(book_id: @book.id)&.destroy

    @book_good = BookGood.create(user_id: current_user.id, book_id: @book.id)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    return if @book.user_id == current_user.id

    @book_good = BookGood.find_by(user_id: current_user.id, book_id: @book.id)

    @book_good.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end
end