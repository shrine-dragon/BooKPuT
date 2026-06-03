class CreateCommentGoods < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_goods do |t|

      t.timestamps
    end
  end
end
