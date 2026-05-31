class BookGoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book
  before_action :ensure_correct_user

  def create
    @bookGood = BookGood.create(user_id: current_user.id, book_id: @book.id)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @bookGood = BookGood.find(user_id: current_user.id, book_id: @book.id)
    @bookGood.destroy
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