class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show search]
  before_action :set_book, only: %i[show edit update destroy report]
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
    if user_signed_in?
      # 現在のユーザーが非表示にしたcomment_idのリストを取得
      hidden_comment_ids = current_user.hidden_comments.pluck(:comment_id)
      # そのID以外のコメントを表示
      @comments = @book.comments.where.not(id: hidden_comment_ids).includes(:user).order(created_at: :desc)
    else
      @comments = @book.comments.includes(:user).order(created_at: :desc)
    end
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

  def report
    @report = ReportedBook.where(user_id: current_user.id, book_id: @book.id).first_or_initialize

    if @report.new_record?
      @report.save
      @status = :created   # 初めての通報
      @message = '投稿を通報しました'
    else
      @status = :exists    # 既に通報済み
      @message = '通報済みの投稿です'
    end

    respond_to do |format|
      format.js
    end
  end

  def search
    @keyword = params[:keyword]
    @books = Book.search(params[:keyword])
    @all_books = @books.length
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
