class AddMenuLabelToPublinatorPublication < ActiveRecord::Migration
  def change
    add_column :publinator_publications, :menu_label, :string
  end
end
