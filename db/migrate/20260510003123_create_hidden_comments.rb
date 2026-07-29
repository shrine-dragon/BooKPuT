class CreateHiddenComments < ActiveRecord::Migration[6.0]
  def change
    create_table :hidden_comments do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.timestamps
    end
  end
end
