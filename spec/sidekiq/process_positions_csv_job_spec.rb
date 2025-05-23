require 'rails_helper'

RSpec.describe ProcessPositionsCsvJob, type: :job do
  let(:csv_file_path) { Rails.root.join('spec/sidekiq/mock_positions.csv') }

  describe '#perform' do
    it 'processes treasury positions from CSV file' do
      expect {
        described_class.new.perform(csv_file_path.to_s)
      }.to change(Position, :count).by(16)  # Total number of positions in mock file

      # Test zero coupon treasury
      zero_coupon = Position.find_by(symbol: '912833LV0')
      expect(zero_coupon).to have_attributes(
        account_number: 'A10000001',
        account_name: 'Individual Account',
        symbol: '912833LV0',
        quantity: 75000.0,
        last_price: 99.729,
        current_value: 74796.75,
        total_gain_loss_percent: 0.10,
        cost_basis_total: 74716.87
      )

      # Test regular treasury note
      treasury_note = Position.find_by(symbol: '91282CMU2')
      expect(treasury_note).to have_attributes(
        account_number: 'A10000001',
        account_name: 'Individual Account',
        symbol: '91282CMU2',
        quantity: 10000.0,
        last_price: 100.274,
        current_value: 10027.40,
        total_gain_loss_percent: 0.72,
        cost_basis_total: 9955.20
      )

      # Test treasury bond
      treasury_bond = Position.find_by(symbol: '912810UJ5')
      expect(treasury_bond).to have_attributes(
        account_number: 'C30000001',
        account_name: 'HSA Account',
        symbol: '912810UJ5',
        quantity: 2000.0,
        last_price: 98.757,
        current_value: 1975.14,
        total_gain_loss_percent: -2.72,
        cost_basis_total: 2030.20
      )
    end

    it 'updates existing positions instead of creating duplicates' do
      # First clear any existing positions
      Position.delete_all

      # Create an existing position
      existing = Position.create!(
        account_number: 'A10000001',
        account_name: 'Individual Account',
        symbol: '912833LV0',
        quantity: 70000.0,
        last_price: 98.0,
        current_value: 70000.0,
        total_gain_loss_percent: 0.0,
        cost_basis_total: 70000.0,
        date: Date.yesterday
      )

      expect {
        described_class.new.perform(csv_file_path.to_s)
      }.to change(Position, :count).by(15) # 16 total positions - 1 existing

      # Reload the position and verify it was updated
      existing.reload
      expect(existing).to have_attributes(
        quantity: 75000.0,
        last_price: 99.729,
        current_value: 74796.75,
        total_gain_loss_percent: 0.10,
        cost_basis_total: 74716.87
      )
    end

    it 'extracts maturity dates from descriptions' do
      described_class.new.perform(csv_file_path.to_s)

      # Test zero coupon treasury
      zero_coupon = Position.find_by(symbol: '912833LV0')
      expect(zero_coupon.maturity_date).to eq(Date.new(2025, 5, 15))

      # Test regular treasury note
      treasury_note = Position.find_by(symbol: '91282CMU2')
      expect(treasury_note.maturity_date).to eq(Date.new(2030, 3, 31))

      # Test treasury bond
      treasury_bond = Position.find_by(symbol: '912810UJ5')
      expect(treasury_bond.maturity_date).to eq(Date.new(2045, 2, 15))

      # Test money market (should have no maturity)
      money_market = Position.find_by(symbol: 'SPAXX**')
      expect(money_market.maturity_date).to be_nil
    end
  end
end
