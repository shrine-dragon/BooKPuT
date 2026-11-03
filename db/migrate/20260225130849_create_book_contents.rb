class CreateBookContents < ActiveRecord::Migration[6.0]
  def change
    create_table :book_contents do |t|
      t.text       :content, null: false
      t.references :book,    null: false, foreign_key: true
      t.timestamps
    end
  end
end
