class CommentGoodsController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_comment

  def create
    return if @comment.user_id == current_user.id

    # current_user.comment_bads.find_by(comment_id: @comment.id)&.destroy

    @book = @comment.book
    
    @comment_good = CommentGood.create(user_id: current_user.id, comment_id: @comment.id)
    
    respond_to do |format|
      format.js
    end
  end

  def destroy
    return if @comment.user_id == current_user.id

    @book = @comment.book

    @comment_good = CommentGood.find_by(user_id: current_user.id, comment_id: @comment.id)
    
    respond_to do |format|
      format.js
    end
  end

  private

  def set_comment
    comment_id = params[:comment_id] || params[:id]
    @comment = Comment.find(comment_id)
  end
end