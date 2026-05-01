class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy]
  before_action :ensure_correct_user, only: %i[edit update destroy]

  def index
    @books = Book.includes(:user, :book_contents)
  end

  def new
    @book = Book.new
    @book.book_contents.build
  end

  def create
    @book = Book.new(book_params)

    if @book.valid?
      if params[:book][:remote_image_url].present? && !@book.image.attached?
        begin
          require 'open-uri'
          file = URI.open(params[:book][:remote_image_url])
          @book.image.attach(io: file, filename: 'book_image.jpg')
        rescue StandardError => e
          logger.error "Image download failed: #{e.message}"
        end
      end

      @book.save
      redirect_to root_path, notice: '投稿しました'
    else
      puts '--- Validation Errors ---'
      puts @book.errors.full_messages
      puts '-------------------------'
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @comment = Comment.new
    @comments = @book.comments.order(created_at: :desc)
  end

  def edit; end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: '更新しました'
    else
      render :edit
    end
  end

  def destroy
    return unless @book.destroy

    redirect_to root_path, notice: '投稿を削除しました'
  end

  private

  def book_params
    params.require(:book).permit(
      :title,
      :image,
      :remote_image_url,
      :delete_image,
      :category_id,
      genre_ids: [],
      book_contents_attributes: %i[id content _destroy]
    ).merge(user_id: current_user.id)
  end

  def set_book
    @book = Book.includes(:book_contents).find(params[:id])
  end

  def ensure_correct_user
    redirect_to root_path if current_user != @book.user
  end
end
