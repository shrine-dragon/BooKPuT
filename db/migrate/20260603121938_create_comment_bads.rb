class CreateCommentBads < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_bads do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.index %i[user_id comment_id], unique: true
      t.timestamps
    end
  end
end
