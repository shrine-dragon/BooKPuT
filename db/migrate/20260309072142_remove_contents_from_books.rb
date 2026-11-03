class RemoveContentsFromBooks < ActiveRecord::Migration[6.0]
  def change
    if column_exists?(:books, :contents)
      remove_column :books, :contents, :text
    end
  end
end
