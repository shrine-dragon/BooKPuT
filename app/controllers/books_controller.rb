class BooksController < ApplicationController
  before_action :set_user
  before_action :ensure_correct_user, only: %i[edit update destroy]

  def index; end

  def new; end

  def create; end
    
  def show; end
    
  def edit; end
    
  def update; end

  def destroy; end

  def set_book
    @book = Book.find(params[:id])
  end

  def ensure_correct_user
    redirect_to root_path if current_user != @user
  end
end
