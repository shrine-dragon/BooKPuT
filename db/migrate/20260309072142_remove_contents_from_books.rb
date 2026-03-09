class RemoveContentsFromBooks < ActiveRecord::Migration[6.0]
  def change
    remove_column :books, :contents, :text
  end
end
