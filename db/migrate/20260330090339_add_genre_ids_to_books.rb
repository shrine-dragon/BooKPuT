class AddGenreIdsToBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :genre_ids, :json
  end
end
