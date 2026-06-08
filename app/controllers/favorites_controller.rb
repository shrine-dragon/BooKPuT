class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book
  before_action :redirect_to_root_path

  def create
    @favorite = Favorite.create(user_id: current_user.id, book_id: @book.id)

    respond_to do |format|
      format.js
    end
  end

  def destroy
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