class RenamePublinatorPagePositionToRowOrder < ActiveRecord::Migration
  def change
    rename_column :publinator_pages, :position, :row_order
  end
end
