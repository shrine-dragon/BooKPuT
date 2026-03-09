class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy]
  before_action :ensure_correct_user, only: %i[edit update destroy]

  def index; end

  def new
    @book = Book.new
    @book.book_contents.build
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to root_path, notice: "投稿が完了しました"
    else
      @book.book_contents.build if @book.book_contents.blank?
      render :new
    end
  end
    
  def show; end
    
  def edit; end
    
  def update
    if @book.update(book_params)
      redirect_to book_path(@book.id)
    else
      render :edit
    end
  end

  def destroy
    if @book.destroy
      redirect_to root_path
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :image, :category_id,
    book_contents_attributes: [:id, :content, :_destroy]).merge(user_id: current_user.id)
  end

  def set_book
    @book = Book.find(params[:id])
  end

  def ensure_correct_user
    redirect_to root_path if current_user != @book.user
  end
end
