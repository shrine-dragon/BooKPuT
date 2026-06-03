class CommentGoodsController < ApplicationController
  before_action :set_comment
  before_action :ensure_correct_user

  def create
    current_user.comment_bads.find_by(comment_id: @comment.id)&.destroy
    @comment_good = CommentGood.create(user_id: current_user.id, comment_id: @comment.id)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @comment_good = CommentGood.find_by(user_id: current_user.id, comment_id: @comment.id)
    @comment_good.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def ensure_correct_user
    redirect_to root_path if @comment.user_id == current_user.id
  end
end