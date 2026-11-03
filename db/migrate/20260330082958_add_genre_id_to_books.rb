class AddGenreIdToBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :genre_id, :integer
  end
end
