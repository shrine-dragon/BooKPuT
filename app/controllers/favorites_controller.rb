class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book

  def create
    return if @book.user_id == current_user.id

    @favorite = Favorite.create(user_id: current_user.id, book_id: @book.id)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    return if @book.user_id == current_user.id
    
    @favorite = Favorite.find_by(user_id: current_user.id, book_id: @book.id)
    @favorite&.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  def redirect_to_root_path
    if @book.user_id == current_user.id
      redirect_to root_path
    end
  end
end