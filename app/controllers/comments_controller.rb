class CommentController < ApplicationController
  before_action :authenticate_user!,   except: [:index]
  before_action :set_comment,          except: [:index, :create]
  before_action :ensure_correct_user,  except: [:index]

  def index
    @book = Book.find(params[:book_id])
    @comments = @user.comments.order(created_at: :desc)
  end

  def create
    @book = Book.find(params[:book_id])
    current_user.comments.build(comment_params)
    @comment.book_id = @book.id

    if @comment.save
      redirect_to book_path(@comment.book), notice: 'コメントしました'
    else
      redirect_to book_path(@book)
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
    redirect_to book_path(@comment.book), notice: '削除しました'
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
