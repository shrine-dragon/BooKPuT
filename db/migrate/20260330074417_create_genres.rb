class CreateGenres < ActiveRecord::Migration[6.0]
  def change
    create_table :genres do |t|

      t.timestamps
    end
  end
end
