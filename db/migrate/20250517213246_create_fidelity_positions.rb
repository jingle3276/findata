class CreateFidelityPositions < ActiveRecord::Migration[8.0]
  def change
    create_table :positions do |t|
      t.string :account_number
      t.string :account_name
      t.string :symbol
      t.integer :quatity
      t.float :last_price
      t.float :current_value
      t.float :total_gain_loss_percent
      t.float :cost_basis_total
      t.date :date

      t.timestamps
    end
  end
end
