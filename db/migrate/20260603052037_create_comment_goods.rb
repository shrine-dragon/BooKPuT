class CreateCommentGoods < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_goods do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.index [:user_id, :comment_id], unique: true
      t.timestamps
    end
  end
end
