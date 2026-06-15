class CreateBookBads < ActiveRecord::Migration[6.0]
  def change
    create_table :book_bads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.index %i[user_id book_id], unique: true
      t.timestamps
    end
  end
end
