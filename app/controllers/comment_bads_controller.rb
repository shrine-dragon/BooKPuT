class CommentBadsController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_comment
  before_action :set_book

  def create
    return if @comment.user_id == current_user.id

    current_user.comment_goods.find_by(comment_id: @comment.id)&.destroy

    @comment_bad = CommentBad.create(user_id: current_user.id, comment_id: @comment.id)
    
    respond_to do |format|
      format.js
    end
  end

  def destroy
    return if @comment.user_id == current_user.id

    @comment_bad = CommentBad.find_by(user_id: current_user.id, comment_id: @comment.id)
    @comment_bad&.destroy
    
    respond_to do |format|
      format.js
    end
  end

  private

  def set_comment
    comment_id = params[:comment_id] || params[:id]
    @comment = Comment.find(comment_id)
  end

  def set_book
    @book = @comment.book
  end
end