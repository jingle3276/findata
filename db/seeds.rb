# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
case Rails.env
when "development"
  puts "Loading development seed data..."

  # Clear existing positions
  puts "Clearing existing positions..."
  Position.destroy_all

  # Create sample positions for US Treasury securities
  positions = Position.create!([
    {
      account_number: "BOND001",
      account_name: "Treasury Portfolio",
      symbol: "912797PT8",    # 13-week T-Bill
      quantity: 100,
      last_price: 99.86,
      current_value: 99860.00,
      total_gain_loss_percent: -0.14,
      cost_basis_total: 100000.00,
      date: Date.today,
      maturity_date: Date.today + 91.days
    },
    {
      account_number: "BOND001",
      account_name: "Treasury Portfolio",
      symbol: "912797QF7",    # 26-week T-Bill
      quantity: 50,
      last_price: 99.92,
      current_value: 49960.00,
      total_gain_loss_percent: -0.08,
      cost_basis_total: 50000.00,
      date: Date.today,
      maturity_date: Date.today + 182.days
    },
    {
      account_number: "BOND001",
      account_name: "Treasury Portfolio",
      symbol: "912797RK5",    # 52-week T-Bill
      quantity: 75,
      last_price: 98.75,
      current_value: 74062.50,
      total_gain_loss_percent: -1.25,
      cost_basis_total: 75000.00,
      date: Date.today,
      maturity_date: Date.today + 364.days
    }
  ])

  puts "Seed data created successfully!"
  puts "Created #{Position.count} Treasury positions"
when "test"
  puts "No test seed data configured"
when "production"
  puts "No production seed data configured"
else
  puts "Environment #{Rails.env} not configured for seeding"
end
