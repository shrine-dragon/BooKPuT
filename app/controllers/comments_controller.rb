class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment,          only: [:edit, :update, :destroy]
  before_action :ensure_correct_user,  only: [:edit, :update, :destroy]

  def create
    @book = Book.find(params[:book_id])
    @comment = current_user.comments.build(comment_params)
    @comment.book_id = @book.id

    if @comment.save
      flash.now[:notice] = 'コメントしました'
      respond_to do |format|
        format.html { redirect_to book_path(@book), notice: 'コメントしました' }
        format.js
      end
    else
      @comments = @book.comments.includes(:user) 
      render "books/show"
    end
  end

  def edit; end
    
  def update
    if @comment.update(comment_params)
      redirect_to book_path(@comment.book), notice: '更新しました'
    else
      redirect_to book_path(@comment.book)
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to book_path(@comment.book), notice: 'コメントを削除しました' }
      format.js
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:text)
  end

  def ensure_correct_user
    redirect_to root_path if current_user != @comment.user
  end
end
