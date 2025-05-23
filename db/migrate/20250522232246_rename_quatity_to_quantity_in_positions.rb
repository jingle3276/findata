class RenameQuatityToQuantityInPositions < ActiveRecord::Migration[8.0]
  def change
    rename_column :positions, :quatity, :quantity
  end
end
