class BookBadsController < ApplicationController
  before_action :set_book
  before_action :ensure_correct_user

  def create
    current_user.book_goods.find_by(book_id: @book.id)&.destroy

    @book_bad = BookBad.create(user_id: current_user.id, book_id: @book.id)
    
    respond_to do |format|
      format.js
    end
  end

  def destroy
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

  def ensure_correct_user
    redirect_to root_path if @book.user_id == current_user.id
  end
end