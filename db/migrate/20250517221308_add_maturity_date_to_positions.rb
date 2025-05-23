class AddMaturityDateToPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :maturity_date, :date
  end
end
